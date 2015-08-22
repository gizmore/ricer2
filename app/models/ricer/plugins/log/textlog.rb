module Ricer::Plugins::Log
  class Textlog
    
    extend Ricer::Base::BaseExtend
    
    def self.irc_message(message, input)
      text = input ? "#{sign(input)} #{message.raw}" : "#{sign(input)} #{message.reply_data}"
      text.force_encoding('UTF-8')
      serverlog(message.server).unknown text
      if message.is_user?
        logfile = userlog(message.sender)
        logfile.unknown text
        logfile.close
      end
      if message.is_channel?
        logfile = channellog(message.receiver)
        logfile.unknown text
        logfile.close 
      end
    end
    
    private

    def self.sign(input); input ? '<<' : '>>'; end

    ##############
    ### Server ###
    ##############
    @@SERVERLOGS = {}
    def self.serverlog(server)
      @@SERVERLOGS[server] ||= bot.botlog.logger("#{server.id}.#{server.domain}.log".force_encoding('UTF-8'))
      @@SERVERLOGS[server]
    end

    #############
    ### Query ###
    #############
    def self.userlog(user)
      server = user.server
      username = user.nickname.gsub(/[^a-zA-Z0-9_]/, '!')
      bot.botlog.logger("#{server.id}.#{server.domain}/user/#{username}.log".force_encoding('UTF-8'))
    end

    ###############
    ### Channel ###
    ###############
    def self.channellog(channel)
      server = channel.server
      channelname = channel.name.gsub(/[^#a-zA-Z0-9]/, '_')
      bot.botlog.logger("#{server.id}.#{server.domain}/channel/#{channelname}.log".force_encoding('UTF-8'))
    end

  end
end
