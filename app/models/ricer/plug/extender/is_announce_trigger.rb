###
### Make the plugin toggle and provide a subscriber list
### No automatic actions are taken, it just offers some helper functions
###
### To work with subscribers, use:
###
### announce_targets{|target| ... }
###
module Ricer::Plug::Extender::IsAnnounceTrigger
  DEFAULT_OPTIONS ||= {
    user: :public,
    user_default: false,
    channel: :operator,
    channel_default: false,
  }
  def is_announce_trigger(trigger_name, options={})
    class_eval do |klass|
      
      merge_options(options, DEFAULT_OPTIONS)
  
      trigger_is trigger_name
      
      has_setting name: :announce, type: :boolean, scope: :user,    permission: options[:user],    default: options[:user_default]    if options[:user]
      has_setting name: :announce, type: :boolean, scope: :channel, permission: options[:channel], default: options[:channel_default] if options[:channel]
  
      if options[:user]
        has_usage :execute_toggle_announce_user, '<boolean>', :scope => :user, :permission => options[:user]
        def execute_toggle_announce_user(boolean)
          get_plugin('Conf/ConfUser').set_var(self, :announce, boolean)
        end
      end

      if options[:channel]
        has_usage :execute_toggle_announce_channel, '<boolean>', :scope => :channel, :permission => options[:channel]
        def execute_toggle_announce_channel(boolean)
          get_plugin('Conf/ConfChannel').set_var(self, :announce, boolean)
        end
      end
      
      def announce_channels(&block)
        Ricer::Irc::Channel.online.each do |channel|
          if get_channel_setting(channel, :announce)
            yield(channel)
          end
        end
        nil
      end

      def announce_users(&block)
        Ricer::Irc::User.online.each do |user|
          if get_user_setting(user, :announce)
            yield(user)
          end
        end
        nil
      end
      
      def announce_targets(&block)
        announce_channels(&block)
        announce_users(&block)
      end
      
    end
  end
end
