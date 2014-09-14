module Ricer::Plug::Params
  class ChannelParam < BaseOnline
    
    def convert_in!(input, message)
      # Split channel:server
      sid = input.substr_from(':')
      input = input.substr_to(':') unless sid.nil?  
      # Get server
      sid = (sid.numeric? ? sid : nil) unless sid.nil?
      server = ServerParam.new(sid).convert_in! unless sid.nil?
      server = message.server if server.nil?
      fail(:err_need_server) if server.nil?

      channels = Ricer::Irc::Channel
      channels = channels.where(:online => online_option) unless online_option.nil?

      sid = server.id
      channel = channels.where(:id => input).first
      channel = channels.where(:name => input, server_id:sid).first if channel.nil?
      channel = channels.where('name LIKE ? AND server_id=?', "#{input}%", sid).first if channel.nil?
      channel = channels.where('name LIKE ? AND server_id=?', "%#{input}%", sid).first if channel.nil?

      channel || failed_input
    end
    
    def convert_out!(value, message)
      channel.displayname
    end
    
  end
end
