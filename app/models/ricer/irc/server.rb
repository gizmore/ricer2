# t.integer  "bot_id",                                 null: false
# t.string   "connector",  default: "Ricer::Net::Irc", null: false
# t.integer  "encoding_id"
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
    
    belongs_to :encoding
    
    scope :online, -> { where(:online => 1) }
    scope :enabled, -> { where(:enabled => 1) }
    scope :in_domain, lambda { |url| joins(:server_url).where('CONCAT(url, ":") LIKE ?', "%#{URI::Generic.domain(url)}:%") }
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
      raise StandardError.new("Server #{self.id} has no URL in server_urls.") if server_url.nil?
      raise StandardError.new("Server #{self.id} has no row in server_nicks.") if server_nicks.length == 0
      # Launch
      bot.log_info "Starting server #{server_url.url}"
      init
      @try_more = true
      try_to_connect
    end
    
    def init
      @initial = true
      @nicknames = server_nicks.each
      @nickname = @nicknames.peek
      @nick_cycle = ''
      @connection = bot.get_connector(self.connector).new(self)
    end
    
    def try_to_connect
      if (bot.running?) && (@try_more)
        begin
          @connection.connect!
        rescue StandardError => e
          bot.log_exception(e)
          false
        end
      end
      # if @connection.connect!
        # process_event('ricer_on_server_handshake', fake_message) and true
      # else
        # process_event('ricer_on_connection_error', fake_message) and false
      # end
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
      rescue StandardError => e
        @nicknames.rewind
        @nickname = @nicknames.peek
        @nick_cycle = '_'+(SecureRandom.base64(3).gsub(/[^a-z0-9]/i, 'a'))
        @nickname.next_cycle(@nick_cycle)
      end
      bot.log_info "Next nickname is #{@nickname.name}"
    end
    
    # def mainloop
      # if @connection.connected?
        # message = @connection.get_message
        # if message.nil?
          # disconnect!
          # sleep 5.seconds
        # else
          # message.server = message.sender = self
          # process message
        # end
      # else
        # sleep 5.seconds
        # try_to_connect
      # end
    # end
    
    def fake_message
      @_fake_message ||= Ricer::Net::Message.fake_message(self)
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
      bot.log_puts "#{self.hostname} >> #{message.reply_data}"
      process_event('ricer_on_reply', message)
    end
    
    def process_event(event, message)
      # Debug
      if message.plugin; bot.log_debug "Server.process_event(#{event}) CAUSE: #{message.plugin.plugin_name}"
      else; bot.log_debug "Server.process_event(#{event}) NEW"; end
      
      # Trigger prepare
      argline, privline = nil, nil
      privmsg = (event == 'on_privmsg')
      
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
          if privmsg
            if argline.nil?
              privmsg = message.is_triggered?
              argline = message.args[1].ltrim(message.trigger_chars)
            elsif plugin.triggered_by?(argline)
              if privline.nil?
                begin
                  privline = true
                  message.args[1] = multiball(message, message.args[1])
                rescue Ricer::ExecutionException => e
                  return plugin.reply e.to_s
                rescue StandardError => e
                  bot.log_exception(e)
                  return plugin.reply e.to_s
                end
              end
              plugin.exec_plugin
            end
          end
          return nil if message.processed? 
        end # .connector_supported?
      end # .plugins_for_event
      nil
    end # def process_event

    #################################
    ### Mu-Mu-Mu-Multiiii Balllll ### (thx Hirsch)
    #################################
    def multiball(message, argline)
      argline = quoteparam_parser(message, argline)
      argline = multicommand_parser(message, argline)
      argline = pipecommand_parser(message, argline)
      argline
    end
    # Parse into ricer2 quote style
    # Params in quotes become a single string by changing space to \x00
    # Quote characters are removed. 
    # '&&' becomes \x00\x00\x00 and '|' becomes \x00\x00
    def quoteparam_part(part); part.gsub('&&', "\x00\x00\x00").gsub("|", "\x00\x00"); end
    def quoteparam_parser(message, argline)
      back = ""
      while argline.length > 0
        # byebug
        part = argline.substr_to('"')
        if part.nil? # no more quotes
          back += quoteparam_part(argline)
          break
        else # append until quote start, append quote without part parser.
          argline.substr_from!('"') # Nibble the part away
          back += quoteparam_part(part) # append until quote start
          part = argline.substr_to('"') # the quoted part
          if part.nil? # Quote mismatch
            back += '"'
            back += quoteparam_part(argline)
            break
          else # Append quoted string
            back += part.gsub(" ", "\x00")
            argline.substr_from!('"') # Nibble the part away
          end
        end
      end
      back
    end

    # Now split by && and exec the commands seperately 
    def multicommand_parser(message, argline)
      firstline = nil
      argline.split(/ +\x00\x00\x00 +/).each do |newline|
        if firstline.nil?
          firstline = newline
        else
          add_nextcommand(message, newline)
        end
      end
      firstline
    end

    def add_nextcommand(message, nextline)
      next_plugin = get_multiplug(nextline)
      next_message = message.clone_chain
      next_message.plugin = next_plugin
      nextline = pipecommand_parser(next_message, nextline)
      next_message.args[1] = nextline
      message.add_chainline(next_message)
    end
    
    def pipecommand_parser(message, argline)
      firstcommand = nil
      argline.split(/ +\x00\x00 +/).each do |pipeline|
        if firstcommand.nil?
          firstcommand = pipeline
        else
          add_pipecommand(message, pipeline)
        end
      end
      firstcommand
    end
    
    def add_pipecommand(message, pipeline)
      pipe_plugin = get_multiplug(pipeline)
      message.add_pipeline(pipe_plugin, pipeline)
    end
    
    def get_multiplug(line)
      bot.plugins.each do |plugin|
        if plugin.triggered_by?(line)
          return plugin
        end
      end
      raise Ricer::ParamException.new(I18n.t('ricer.err_multicommand'))
    end
    
    #############
    ### Cache ###
    #############
    def load_user(nickname)
      unless user = Ricer::Irc::User.global_cache["#{nickname.downcase}:#{self.id}"]
        user = Ricer::Irc::User.where({server_id: self.id, nickname: nickname}).first
      end
      user
    end
    
    def load_channel(channel_name)
      return nil unless Ricer::Irc::Lib.instance.channelname_valid?(channel_name)
      unless channel = Ricer::Irc::Channel.global_cache["#{channel_name.downcase}:#{self.id}"]
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
