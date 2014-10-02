module Ricer::Plug::Params
  class TargetParam < BaseOnline
    
    DEFAULT_OPTIONS = { channels:'1', users:'1', connectors:'*', online: nil, multiple: '1' }
    
    def default_options; DEFAULT_OPTIONS; end

    def do_channels; options[:channels] == '1'; end
    def do_users; options[:users] == '1'; end
    
    def convert_in!(input, message)
      
      input = input.gsub(/\s+/, '').gsub(';',',').downcase
      dc, du = do_channels, do_users
      
      @server_param ||= ServerParam.new(options)
      
      byebug
      
      users = Ricer::Irc::User
      channels = Ricer::Irc::Channel
      if ((o = online_option) != nil)
        users = users.where(:online => o)
        channels = channels.where(:online => o)
      end
      
      targets, servers, patterns = [], [], []
      server_args = ''
      input.split(',').each do |_pattern|
        if (server_arg = _pattern.substr_from(':'))
          server_args += ',' + server_arg
          _pattern.substr_to!(':')
        end
        _pattern.gsub!('*', '%')
        patterns.push(_pattern)
      end
      
      byebug
      server_args = message.server.id.to_s if server_args.empty? && message

      byebug
      servers = @server_param.convert_in!(server_args.ltrim(','), message)
      
      patterns.each do |pattern|
        if dc
          channels.where('server_id IN (?) AND name LIKE ?', servers, pattern).each do |channel|
            targets.push(channel) unless targets.include?(channel)
          end
        end
        if du
          users.where('server_id IN (?) AND nickname LIKE ?', servers, pattern).each do |user|
            targets.push(user) unless targets.include?(user)
          end
        end
      end
      failed_input if targets.length == 0      
      fail('ricer.plug.params.err_ambigious') unless options_multiple || (targets.length == 1)
      options_multiple ? targets : targets.first
    end

    def convert_out!(target, message)
      target.displayname
    end

  end
end
