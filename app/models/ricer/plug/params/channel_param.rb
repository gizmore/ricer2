module Ricer::Plug::Params
  class ChannelParam < Base

    def convert_in!(input, options, message)
      # Split channel:server
      sid = input.substr_from(':')
      input = input.substr_to(':') unless sid.nil?  
      # Get server
      sid = (sid.numeric? ? sid : nil) unless sid.nil?
      server = ServerParam.new(sid).convert_in! unless sid.nil?
      server = message.server if server.nil?
      fail(:err_need_server) if server.nil?

      sid = server.id
      channel = Ricer::Irc::Channel.where(:id => input).first
      channel = Ricer::Irc::Channel.where(:name => input, server_id:sid).first if channel.nil?
      channel = Ricer::Irc::Channel.where('name LIKE ? AND server_id=?', "#{input}%", sid).first if channel.nil?
      channel = Ricer::Irc::Channel.where('name LIKE ? AND server_id=?', "%#{input}%", sid).first if channel.nil?

      failed_input if channel.nil?
      channel
    end
    
    def convert_out!(value, options, message)
      channel.displayname
    end
    
  end
end
