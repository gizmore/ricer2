module Ricer::Plugins::Log
  class Textlog
    
    def self.irc_message(message, input)
      text = input ? "#{sign(input)} #{message.raw}" : "#{sign(input)} #{message.reply_data}"
      serverlog(message.server).unknown text
      userlog(message.sender).unknown text if message.is_user?
      channellog(message.receiver).unknown text if message.is_channel?
    end
    
    private

    def self.sign(input); input ? '<<' : '>>'; end
    def self.bot; Ricer::Bot.instance; end

    ##############
    ### Server ###
    ##############
    @@SERVERLOGS = {}
    def self.serverlog(server)
      @@SERVERLOGS[server] ||= bot.botlog.logger("#{server.id}.#{server.domain}.log")
      @@SERVERLOGS[server]
    end

    #############
    ### Query ###
    #############
    @@USERLOGS = {}
    def self.userlog(user)
      if @@USERLOGS[user].nil?
        server = user.server
        username = user.nickname.gsub(/[^a-zA-Z0-9_]/, '!')
        @@USERLOGS[user] = bot.botlog.logger("#{server.id}.#{server.domain}/user/#{username}.log")
      end
      @@USERLOGS[user]
    end

    ###############
    ### Channel ###
    ###############
    @@CHANNELLOGS = {}
    def self.channellog(channel)
      if @@CHANNELLOGS[channel].nil?
        server = channel.server
        channelname = channel.name.gsub(/[^#@a-zA-Z0-9_]/, '_')
        @@CHANNELLOGS[channel] = bot.botlog.logger("#{server.id}.#{server.domain}/channel/#{channelname}.log")
      end
      @@CHANNELLOGS[channel]
    end

  end
end
