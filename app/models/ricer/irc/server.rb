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
    def should_cache?; self.enabled == true; end
    
    attr_reader   :connection, :nickname
    attr_accessor :started_up, :try_more
        
    has_one  :server_url
    has_many :server_nicks
    
    scope :online, -> { where(:online => 1) }
    scope :enabled, -> { where(:enabled => 1) }
    scope :in_domain, lambda { |url| joins(:server_url).where('url LIKE ?', "%.#{URI::Generic.domain(url)}:%") }
    
    def bot; Ricer::Bot.instance; end
    
    def uri; server_url.uri; end
    def url; server_url.url; end
    def ssl?; server_url.ssl?; end
    def hostname; server_url.hostname; end
    def name; uri.domain; end
    def displayname; "#{self.id}-#{name}"; end
    def guid; "*:#{self.id}"; end
    def peer_verify; server_url.peer_verify; end
    
    def channels; Ricer::Irc::Channel.where(:server_id => self.id); end
    def joined_channels; channels.where(:online => true);  end
    
    def displayname; "#{self.id}-#{uri.domain}"; end
    
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
      @connection = Ricer::Net::Irc::Connection.new(self)
      unless @connection.connect!
        process_event('ricer_on_connection_error', fake_message)
      else
        process_event('ricer_on_connection_success', fake_message)
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
        @nick_cycle = '_'+SecureRandom.base64(3)
        @nickname.next_cycle(@nick_cycle)
      end
      bot.log_info "Next nickname is #{@nickname.name}"
    end
    
    def mainloop
      if @connection.connected?
        message = @connection.get_message
        if message.nil?
          disconnect!
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
      self.save!
      @connection.disconnect(message)
    end
    
    def connected?; @connection.connected?; end
    
    def process(message)
      if @initial
        @started_up = true
        @initial = false
        process_event('ricer_on_server_handshake', message)
      end
      process_event("ricer_on_receive", message)
      process_event("on_#{message.command}", message)
    end

    def ricer_replies_to(message)
      puts "#{self.hostname} >> #{message.reply_data}"
      process_event('ricer_on_reply', message)
    end
    
    def process_event(event, message)
      bot.log_debug "Server.process_event(#{event}, #{message.plugin_id})"
      
      is_privmsg = event == 'on_privmsg'
      
      bot.plugins.each do |plugin|
        # bot.log_debug "Checking if #{plugin.plugin_name} responds to #{event}"
        if plugin.respond_to?(event)
          begin
            # bot.log_debug "Calling #{plugin.plugin_name}.#{event}"
            plugin.clone_plugin(message).send(event)
          rescue Exception => e
            bot.log_exception e
          end
        end
        if message.unprocessed? && is_privmsg
          triggered ||= message.is_triggered?
          if triggered
            argline ||= message.privmsg_line.ltrim(message.trigger_chars)
            if plugin.triggered_by?(argline)
              plug = plugin.clone_plugin(message)
              plug.exec_plugin(plug)
            end
          end 
        end
      end
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