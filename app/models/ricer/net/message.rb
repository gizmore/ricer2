module Ricer::Net
  class Message
    
    attr_reader :raw, :time

    attr_accessor :prefix, :server
    attr_accessor :sender, :receiver, :command, :args # , :argline
    
    attr_accessor :reply_to, :reply_prefix, :reply_data  # These are set when there is a reply for this msg generated, else all are nil
    
    attr_accessor :plugin_id, :commandline, :errorneous
    
    def bot; self.class.bot; end
    def plugin; bot.plugin_by_id(@plugin_id); end
    def self.bot; Ricer::Bot.instance; end

    def processed?; @processed != nil; end
    def unprocessed?; @processed.nil?; end
    def processed=(bool) @processed = bool ? true : nil; end;

    def self.fake_message(server, text=nil, reply_to=nil)
      message = new
      message.server = server
      message.sender = bot
      message.receiver = bot
      message.reply_to = reply_to||bot
      message.reply_text(text||'Somethings wrong!')
    end
    
    def initialize(rawmessage=nil)
      Thread.current[:ricer_message] = self
      @time = Time.new
      @raw = rawmessage
    end
    
    def to_s
      if incoming?
        super + ":O <= " + @raw
      else
        super + ":] => " + @reply_data
      end
    end
    
    def incoming?; @reply_data.nil? end
    def outgoing?; !incoming?; end
    
    def self.outgoing(to, command, argline)
      message = new()
      message.server = to.server
      message.command = command
      message.sender = bot
      message.receiver = to
      message.commandline = argline
    end
    
    def is_ricer?
      is_user? && sender.is_ricer?
    end
    
    def is_user?
      sender && (sender.is_a?(Ricer::Irc::User))
    end
    
    def is_server?
      receiver && (receiver.is_a?(Ricer::Irc::Server))
    end
    
    def is_channel?
      receiver && (receiver.is_a?(Ricer::Irc::Channel))
    end
    
    def is_query?
      receiver.nil? || (receiver.is_a?(Ricer::Irc::User))
    end

    def channel_id
      return nil if is_query?
      return receiver.id
    end
    
    def scope
      is_channel? ? Ricer::Irc::Scope::CHANNEL : Ricer::Irc::Scope::USER
    end
    
    def scopes
      return [:bot, :server, :channel, :user] if is_channel?
      return [:bot, :server, :user]
    end
    
    def is_triggered?
      return true if is_query?
      return false unless is_channel?
      (receiver.triggers||server.triggers).include?(privmsg_line[0])
    end
    
    def is_trigger_char?
      trigger_chars.include?(privmsg_line[0])
    end
    
    def trigger_chars
      is_query? ? server.triggers : receiver.triggers||server.triggers
    end
    
    def trigger_char
      trigger_chars[0] rescue '' 
    end
    
    def reply_text(text)
      self.reply_data = text
      @time = Time.new
      self
    end
    
    def reply_message(text)
      self.clone.reply_text(text)
    end
    
    def reply_clone
      self.clone.setup_reply
    end
    
    def setup_reply
      self.reply_prefix = reply_prefix_text
      self.setup_target(reply_target)
    end
    
    def setup_target(target)
      self.reply_to = target
      self
    end
    
    def reply_target
      return sender if is_query?
      return receiver
    end
    
    def reply_prefix_text
      return "#{sender.name}: " if is_channel?
      return ''
    end
    
    def privmsg_args
      @argv ||= args[1].split(/ +/)
      @argv
    end
    
    def privmsg_line
      args[1]
    end
    
    #############
    ### Pipes ###
    #############
    def add_chainline(plugin, line)
      @chainplugs ||= [];       @chainlines ||= []
      @chainplugs.push(plugin); @chainlines.push(line)
    end

    def add_pipeline(plugin, line)
      @pipeplugs ||= [];       @pipelines ||= []
      @pipeplugs.push(plugin); @pipelines.push(line)
    end
    
    def chain!
      return false if @chainlines.nil? || @chainlines.length == 0
      plugin = @chainplugs.shift
      line = @chainlines.shift
      self.args[1] = line
      plugin.exec_plugin
    end
    
    def pipe!(text)
      return false if @errorneous || @pipelines.nil? || @pipelines.length == 0
      plugin = @pipeplugs.shift
      line = @pipelines.shift + ' ' + text
      self.args[1] = line
      plugin.exec_plugin
    end
    

  end
end
