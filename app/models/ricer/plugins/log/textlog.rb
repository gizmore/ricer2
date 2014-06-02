module Ricer::Plugins::Log
  class Textlog
    
    def self.irc_message(irc_message, input)
      message = "#{sign(input)} #{irc_message.raw}"
      serverlog(irc_message.server).unknown message
      userlog(irc_message.user).unknown message unless irc_message.user.nil?
      channellog(irc_message.channel).unknown message unless irc_message.channel.nil?
    end
    
    private

    def self.sign(input); input ? 'IN' : 'OUT'; end
    def self.bot; Ricer::Bot.instance; end

    ##############
    ### Server ###
    ##############
    @@SERVERLOGS = {}
    def self.serverlog(server)
      @@SERVERLOGS[server] ||= bot.logger("#{server.id}.#{server.domain}.log")
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
        @@USERLOGS[user] = bot.logger("#{server.id}.#{server.domain}/user/#{username}.log")
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
        @@CHANNELLOGS[channel] = bot.logger("#{server.id}.#{server.domain}/channel/#{channelname}.log")
      end
      @@CHANNELLOGS[channel]
    end

  end
end
