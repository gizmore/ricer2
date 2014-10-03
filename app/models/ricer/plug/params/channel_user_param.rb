module Ricer::Plug::Params
  class ChannelUserParam < Base

    def convert_in!(input, message)
      channel = message.channel
      users = channel.users.online.human
      user = users.where(:nickname => input, server_id:sid).first if user.nil?
      user = users.where('nickname LIKE ? AND server_id=?', "#{name}%", sid).first if user.nil?
      user = users.where('nickname LIKE ? AND server_id=?', "%#{name}%", sid).first if user.nil?
      user || failed_input
    end
    
    def convert_out!(user, message)
      user.displayname
    end
    
  end
end
