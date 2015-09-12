module Ricer::Net
  class Message
    
    include Ricer::Base::Base
    
    SCOPES_CHANNEL ||= [:bot, :server, :channel, :user]
    SCOPES_PRIVATE ||= [:bot, :server, :user]
    
    attr_reader :raw, :time
    
    attr_reader :pipeplugs, :pipelines

    attr_accessor :prefix, :server
    attr_accessor :sender, :receiver, :command, :args
    
    attr_accessor :reply_to, :reply_prefix, :reply_data  # These are set when there is a reply for this msg generated, else all are nil
    
    attr_accessor :plugin, :commandline, :errorneous
    
    def processed?; @processed; end
    def unprocessed?; !@processed; end
    def processed=(bool) @processed = bool ? true : false; end
    
    def reply_encoding_iso
      reply_to.nil? ?
        (server.encoding || bot.encoding).to_label :
        (reply_to.encoding || server.encoding || bot.encoding).to_label
    end

    def self.fake_message(server, text=nil, reply_to=nil)
      #bot.log_debug("Net/Message::fake_message(#{server.displayname})")
      # Create a message, but don´t remember in thread
      old_message = Thread.current[:ricer_message] # old remembered
      message = new(nil) # the new fake
      Thread.current[:ricer_message] = old_message if old_message # restore
      message.server = server
      message.sender = bot
      message.receiver = bot
      message.reply_to = reply_to||server
      message.reply_text(text||'Somethings wrong!')
    end
    
    def initialize(rawmessage=nil)
      #bot.log_debug("Net/Message#new(#{rawmessage}) NEW!")
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
    
    def hostmask
      #bot.log_debug("Message#hostmask returns #{prefix.rsubstr_from('@')}")
      prefix.rsubstr_from('@')
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

    def channel
      current_message.is_channel? ? receiver : nil
    end
    
    def channel_id
      current_message.is_channel? ? receiver.id : nil
    end
    
    def scope
      is_channel? ? Ricer::Irc::Scope::CHANNEL : Ricer::Irc::Scope::USER
    end
    
    def scopes
      is_channel? ? SCOPES_CHANNEL : SCOPES_PRIVATE
    end
    
    def is_triggered?
      return false if privmsg_line == ""
      return true if is_query?
#      return false unless is_channel?
      return (receiver.triggers||server.triggers).include?(privmsg_line[0])
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
      (self.reply_data, @time = text, Time.now) and return self
    end
    
    def reply_message(text)
      self.clone.reply_text(text)
    end
    
    def reply_clone
      #self.clone.setup_reply
      self.setup_reply
    end
    
    def setup_reply
      self.reply_prefix = reply_prefix_text
      self.setup_target(reply_target)
    end
    
    def setup_target(target)
      self.reply_to = target
      self
    end
    
    def target
      self.reply_to
    end
    
    def reply_target
      is_query? ? sender : receiver
    end
    
    def reply_prefix_text
      is_channel? ? "#{sender.name}: ": ''
    end
    
    def privmsg_line
      args[1]
    end
    
    #############
    ### Pipes ###
    #############
    def forked!
      @forked ||= 0
      @forked += 1
      @forked
    end
    
    def forked?
      @forked ||= 0
      @forked > 0
    end
    
    def joined!
      @forked ||= 0
      @forked -= 1
      @forked
    end
    
    def clone_chain
      next_message = self.clone
      next_message.args = self.args.clone
      next_message.clean_chain
    end
    
    def clean_chain
      @pipeout = ''
      @pipeplugs, @pipelines, @chainplugs = [], [], []
      self
    end

    def add_chainline(message)
      #bot.log_debug("Message#add_chainline(#{message.args[1]})")
      @chainplugs ||= []
      @chainplugs.push(message)
      self
    end

    def add_pipeline(plugin, line)
      @pipeout ||= ''
      @pipeplugs ||= []; @pipelines ||= []
      @pipeplugs.push(plugin); @pipelines.push(line)
      #bot.log_debug("Message#add_pipeline(#{line}) to #{self.args[1]}. Chains: #{@chainplugs.length rescue 0}. Pipes: #{@pipeplugs.length}")
      self
    end
    
    def chain_message
      return nil if (@errorneous) || (@chainplugs.nil?) || (@chainplugs.length == 0)
      #bot.log_debug("Polling next chained command: #{@chainplugs[0].args[1]}")
      @chainplugs.shift
    end
    
    def chained?
      (!@errorneous) && (@chainplugs) && (@chainplugs.length > 0)
    end
    
    def chain!
      next_message = chain_message
      # Copy data
      self.args[1] = next_message.args[1]
      self.plugin = next_message.plugin
      @pipeout = ''
      @pipelines = next_message.pipelines
      @pipeplugs = next_message.pipeplugs
      #bot.log_debug("Next chained command: #{self.args[1]}. Pipes: #{@pipeplugs.length rescue 0}")
      self.plugin.exec_plugin
      return true
    end
    
    def pipe?(text=nil)
      return false if @errorneous || @pipelines.nil? || (@pipelines.length == 0)
      @pipeout += text + "\n" if text
      return true
    end
    
    def pipe!
      plugin = @pipeplugs.shift
      line = @pipelines.shift + ' ' + @pipeout
      self.args[1] = line.rtrim("\n")
      @pipeout = ''
      #bot.log_debug("Next piped command: #{self.args[1]}. Pipes left: #{@pipeplugs.length}")
      plugin.exec_plugin
      return true
    end

  end
end
