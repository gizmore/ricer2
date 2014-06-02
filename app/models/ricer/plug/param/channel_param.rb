module Ricer::Plug::Param
  class ChannelParam < Base

    def self.get_arg(server, arg, message)
      sid = arg.substr_from(':')
      sid = (sid.numeric? ? sid : nil) unless sid.nil?
      server = Ricer::Irc::Server.where(:id => sid) unless sid.nil?
      return nil if server.nil?
      arg = arg.substr_from(':') unless sid.nil?  
      sid = server.id
      channel = Ricer::Irc::Channel.where(:id => arg).first
      channel = Ricer::Irc::Channel.where(:name => arg, server_id:sid).first if channel.nil?
      channel = Ricer::Irc::Channel.where('name LIKE ? AND server_id=?', "#{arg}%", sid).first if channel.nil?
      channel = Ricer::Irc::Channel.where('name LIKE ? AND server_id=?', "%#{arg}%", sid).first if channel.nil?
      channel
    end
    
  end
end
