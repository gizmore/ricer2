module Ricer::Plug::Params
  class UserParam < Base
    
    def default_options; { online: nil, offline: nil }; end
    
    def online_option
      return true if options[:online]
      return false if options[:offline]
      return nil
    end

    def convert_in!(input, message)
      
      # Get server from user:sid or message
      sid = input.substr_from(':')
      sid = (sid.numeric? ? sid : nil) unless sid.nil?
      server = Ricer::Irc::Server.where(:id => sid).first unless sid.nil?
      server = message.server if sid.nil?
      failed_input if server.nil?

      # 
      name = input.substr_to(':') unless sid.nil?
      name = input if name.nil?
      sid = server.id
      
      users = Ricer::Irc::User
      users = users.where(:online => online_option) unless online_option.nil?
      
      user = nil
      # user = users.where(:id => input).first
      user = users.where(:nickname => input, server_id:sid).first if user.nil?
      user = users.where('nickname LIKE ? AND server_id=?', "#{name}%", sid).first if user.nil?
      user = users.where('nickname LIKE ? AND server_id=?', "%#{name}%", sid).first if user.nil?
      
      failed_input if user.nil?
      
      user
     
    end

    def convert_out!(value, message)
      value.displayname
    end

    
  end
end
