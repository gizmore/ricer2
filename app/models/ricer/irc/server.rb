# t.integer  "bot_id",                                 null: false
# t.string   "connector",  default: "Ricer::Net::Irc", null: false
# t.string   "triggers",   default: ",",               null: false
# t.integer  "throttle",   default: 3,                 null: false
# t.float    "cooldown",   default: 0.8,               null: false
# t.boolean  "enabled",    default: true,              null: false
# t.boolean  "online",     default: false,             null: false
# t.datetime "created_at"
# t.datetime "updated_at"
module Ricer::Irc
  class Server < ActiveRecord::Base
    
    with_global_orm_mapping
    def should_cache?; true; end # self.enabled == true; end
    
    attr_reader   :connection, :nickname
    attr_accessor :started_up, :try_more
        
    has_one  :server_url
    has_many :server_nicks
    
    scope :online, -> { where(:online => 1) }
    scope :enabled, -> { where(:enabled => 1) }
    scope :in_domain, lambda { |url| joins(:server_url).where('url LIKE ?', "%.#{URI::Generic.domain(url)}:%") }
    scope :with_url_like, lambda { |url| joins(:server_url).where('url LIKE ?', "%#{url}%") }
    validates_numericality_of :cooldown, :larger_than => 0.0, :max => 2.0
    validates_numericality_of :throttle, :min => 1.0, :max => 800, :float => false
    validates_format_of :triggers, :with => /[-.,*!\"\''§$%&]/
    
    def bot; Ricer::Bot.instance; end
    def lib; Ricer::Irc::Lib.instance; end
    
    def uri; server_url.uri; end
    def url; server_url.url; end
    def ssl?; server_url.ssl?; end
    def domain; server_url.domain; end
    def hostname; server_url.hostname; end
    def port; server_url.port; end
    def name; uri.domain; end
    def displayname; "#{self.id}-#{name}"; end
    def guid; "*:#{self.id}"; end
    def peer_verify; server_url.peer_verify; end
    def connector_symbol; self.connector.to_sym; end

    def users; Ricer::Irc::User.where(:server_id => self.id); end
    def channels; Ricer::Irc::Channel.where(:server_id => self.id); end
    
    def displayid; self.online ? "\x02#{self.id}\x02" : self.id.to_s; end
    def displayname; "#{displayid}-#{uri.domain}"; end

    def started_up?; @started_up != nil; end
    
    def startup
      bot.log_info "Starting server #{server_url.url}"
      Ricer::Thread.execute do
        @try_more = true
        init
        while (bot.running?) && (@try_more)
          begin
            mainloop
          rescue => e
            bot.log_exception(e)
          end
        end
      end
    end
    
    def init
      @initial = true
#      @nicknames = Ricer::Irc::ServerNick.where(:server_id => self.id).sorted.load.each
#      @nicknames = server_nicks.sorted.load.each
      @nicknames = server_nicks.each
      @nickname = @nicknames.peek
      @nick_cycle = ''
      @connection = bot.get_connector(self.connector).new(self)
      unless @connection.connect!
        process_event('ricer_on_connection_error', fake_message)
      else
        process_event('ricer_on_server_handshake', fake_message)
      end
    end
    
    def login(message)
      @connection.login(message, @nickname)
    end
    def send_nick(message)
      @connection.send_nick(message, @nickname)
    end
    def authenticate(message=nil)
      @connection.authenticate(message||fake_message, @nickname)
    end
    def next_nickname
      begin
        @nickname = @nicknames.next
      rescue => e
        @nicknames.rewind
        @nickname = @nicknames.peek
        @nick_cycle = '_'+(SecureRandom.base64(3).gsub(/[^a-z0-9]/i, 'a'))
        @nickname.next_cycle(@nick_cycle)
      end
      bot.log_info "Next nickname is #{@nickname.name}"
    end
    
    def mainloop
      if @connection.connected?
        message = @connection.get_message
        if message.nil?
          disconnect!
          sleep 5.seconds
        else
          message.server = message.sender = self
          process message
        end
      else
        sleep 5.seconds
        init
      end
    end
    
    def fake_message
      @connection.fake_message
    end
    
    def send_quit(text)
      @connection.send_quit(fake_message, text)
    end
    
    def disconnect!(message=nil)
      self.online = false
      if self.persisted?
        self.save!
      end
      @connection.disconnect(message)
    end
    
    def connected?; @connection.connected?; end
    
    def process(message)
      if @initial
        @initial, @started_up = false, true
        process_event('ricer_on_server_connected', message)
      end
      process_event("on_#{message.command}", message)
      process_event("ricer_on_receive", message)
    end

    def ricer_replies_to(message)
      bot.puts_mutex.synchronize do
        puts "#{self.hostname} >> #{message.reply_data}"
      end
      process_event('ricer_on_reply', message)
    end
    
    def process_event(event, message)
      if message.plugin_id
        bot.log_debug "Server.process_event(#{event}) CAUSE: #{message.plugin.plugin_name}"
      else
        bot.log_debug "Server.process_event(#{event}) NEW"
      end
      
      is_privmsg = event == 'on_privmsg'
      
      # all plugins that have this event registered
      # sorted by priority
      bot.plugins_for_event(event).each do |plugin|
        # sieve out unsupported connectors
        if plugin.connector_supported?(self.connector)
          # Simply call the func after cloning the plugin
          begin
            plugin.send(event)
          rescue StandardError => e
            bot.log_exception e
          end
          
          # PRIVMSG trigger has_usage
          # Done via calling plugin.exec_plugin which
          # calls the exec_function chain of a plugin
          if is_privmsg
            triggered ||= message.is_triggered?
            if triggered
              argline ||= message.privmsg_line.ltrim(message.trigger_chars)
              if plugin.triggered_by?(argline)
                plugin.exec_plugin
              end
            end 
          end
          
          return nil unless message.unprocessed? 

        end # .connector_supported?
      end # .plugins_for_event
      nil
    end # def process_event
    
    #############
    ### Cache ###
    #############
    def load_user(nickname)
      unless user = Ricer::Irc::User.global_cache[nickname.downcase]
        user = Ricer::Irc::User.where({server_id: self.id, nickname: nickname}).first
      end
      user
    end
    
    def load_channel(channel_name)
      return nil unless Ricer::Irc::Lib.instance.channelname_valid?(channel_name)
      unless channel = Ricer::Irc::Channel.global_cache[channel_name.downcase]
        channel = Ricer::Irc::Channel.where(:name => channel_name, :server_id => self.id).first
      end
      channel
    end
    
    #####################
    ### Communication ###
    #####################
    def localize!; self; end
    def action_to(target, text); notice_to(target, lib.action(text)); end
    def message_to(target, text); ((target.class < Ricer::Irc::User) && (target.wants_notice?)) ? notice_to(target, text) : privmsg_to(target, text); end
    def notice_to(target, text); @connection.send_notice(Ricer::Net::Message.fake_message(self, text, target), text); end
    def privmsg_to(target, text); @connection.send_privmsg(Ricer::Net::Message.fake_message(self, text, target), text); end
    
  end
end
