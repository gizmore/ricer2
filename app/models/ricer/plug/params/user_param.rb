module Ricer::Plug::Params
  class UserParam < Base

    def convert_in!(input, options, message)
      
      sid = input.substr_from(':')
      sid = (sid.numeric? ? sid : nil) unless sid.nil?
      server = Ricer::Irc::Server.where(:id => sid) unless sid.nil?
      return nil if server.nil?
      name = input.substr_until(':') unless sid.nil?  
      sid = server.id
      user = Ricer::Irc::User.where(:id => input).first
      user = Ricer::Irc::User.where(:nickname => input, server_id:sid).first if user.nil?
      user = Ricer::Irc::User.where('nickname LIKE ? AND server_id=?', "#{name}%", sid).first if user.nil?
      user = Ricer::Irc::User.where('nickname LIKE ? AND server_id=?', "%#{name}%", sid).first if user.nil?
      
      failed_input if user.nil?
      user
     
    end

    def convert_out!(value, options, message)
      value.displayname
    end

    
  end
end
