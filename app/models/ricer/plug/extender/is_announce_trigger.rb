module Ricer::Plug::Extender::IsAnnounceTrigger

  DEFAULT_OPTIONS = {
    user: :public,
    user_default: false,
    channel: :operator,
    channel_default: false,
  }

  def is_announce_trigger(trigger_name, options={channel:true, user:true})
    
    options = merge_options(options, DEFAULT_OPTIONS)

    class_eval do |klass|
      
      trigger_is trigger_name
      
      has_setting name: :announce, type: :boolean, scope: :user,    permission: options[:user],    default: options[:user_default]    if options[:user]
      has_setting name: :announce, type: :boolean, scope: :channel, permission: options[:channel], default: options[:channel_default] if options[:channel]
  
      has_usage :execute_toggle_announce, '<boolean>'
      def execute_toggle_announce(boolean)
        boolean = boolean ? '1' : '0'
        methodn = @message.is_query? ? 'confu' : 'confc'
        exec_line("#{methodn} #{trigger} announce #{boolean}")
      end
      
      def announce_channels(&block)
        Ricer::Irc::Channel.online.each do |channel|
          if get_channel_setting(channel, :announce)
            yield(channel)
          end
        end
      end

      def announce_users(&block)
        Ricer::Irc::User.online.each do |user|
          if get_user_setting(user, :announce)
            yield(user)
          end
        end
      end
      
      def announce_targets(&block)
        announce_channels(&block)
        announce_users(&block)
      end
      
    end
    
  end
  
end
