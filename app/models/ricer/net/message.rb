module Ricer::Net
  class Message
    
    include Ricer::Base::Base
    
    attr_reader :raw, :time
    
    attr_reader :pipeplugs, :pipelines

    attr_accessor :prefix, :server
    attr_accessor :sender, :receiver, :command, :args # , :argline
    
    attr_accessor :reply_to, :reply_prefix, :reply_data  # These are set when there is a reply for this msg generated, else all are nil
    
    attr_accessor :plugin, :commandline, :errorneous
    
    def processed?; @processed != nil; end
    def unprocessed?; @processed.nil?; end
    def processed=(bool) @processed = bool ? true : nil; end;
    
    def reply_encoding_iso
      reply_to.nil? ?
        (server.encoding || bot.encoding).to_label :
        (reply_to.encoding || server.encoding || bot.encoding).to_label
    end

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
    # def debug_pipes
      # bot.log_puts("Chainplugs: #{@chainplugs.inspect}")
      # bot.log_puts("Chainlines: #{@chainlines.inspect}")
      # bot.log_puts("Pipeplugs: #{@pipeplugs.inspect}")
      # bot.log_puts("Pipelines: #{@pipelines.inspect}")
      # bot.log_puts("")
    # end
    
    def forked!
      @forked = true
    end
    
    def forked?
      @forked
    end
    
    def joined!
      @forked = false
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
      bot.log_debug("Message#add_chainline(#{message.args[1]})")
      @chainplugs ||= []
      @chainplugs.push(message)
      self
    end

    def add_pipeline(plugin, line)
      @pipeout ||= ''
      @pipeplugs ||= []; @pipelines ||= []
      @pipeplugs.push(plugin); @pipelines.push(line)
      bot.log_debug("Message#add_pipeline(#{line}) to #{self.args[1]}. Chains: #{@chainplugs.length rescue 0}. Pipes: #{@pipeplugs.length}")
      self
    end
    
    # def start_capture
      # @capture = true
    # end
#     
    # def stop_capture
      # @capture = false
      # back = @pipeout.rtrim(lib.comma)
      # @pipeout = ''
      # back
    # end
    
    def chain_message
      return nil if (@errorneous) || (@chainplugs.nil?) || (@chainplugs.length == 0)
      bot.log_debug("Polling next chained command: #{@chainplugs[0].args[1]}")
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
      bot.log_debug("Next chained command: #{self.args[1]}. Pipes: #{@pipeplugs.length rescue 0}")
      # Thread.current[:ricer_message] = self
      self.plugin.exec_plugin
      return true
    end
    
    def pipe?(text=nil)
      return false if @errorneous || @pipelines.nil? || (@pipelines.length == 0)
      @pipeout += text + "\n" if text
      return true
    end
    
    def pipe!
      # Capture catch
#      (@pipeout += text + comma) and (return true) if @capture
      plugin = @pipeplugs.shift
      line = @pipelines.shift + ' ' + @pipeout
      self.args[1] = line.rtrim("\n")
      @pipeout = ''
      bot.log_debug("Next piped command: #{self.args[1]}. Pipes left: #{@pipeplugs.length}")
      plugin.exec_plugin
      return true
    end

  end
end
