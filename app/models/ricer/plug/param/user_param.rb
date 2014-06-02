module Ricer::Plug::Param
  class UserParam < Base

    def self.get_arg(server, arg, message)
      
      sid = arg.substr_from(':')
      sid = (sid.numeric? ? sid : nil) unless sid.nil?
      server = Ricer::Irc::Server.where(:id => sid) unless sid.nil?
      return nil if server.nil?
      name = arg.substr_until(':') unless sid.nil?  
      sid = server.id
      user = Ricer::Irc::User.where(:id => arg).first
      user = Ricer::Irc::User.where(:nickname => arg, server_id:sid).first if user.nil?
      user = Ricer::Irc::User.where('nickname LIKE ? AND server_id=?', "#{name}%", sid).first if user.nil?
      user = Ricer::Irc::User.where('nickname LIKE ? AND server_id=?', "%#{name}%", sid).first if user.nil?
      user
     
    end
    
  end
end