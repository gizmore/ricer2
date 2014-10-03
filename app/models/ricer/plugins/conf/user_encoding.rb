module Ricer::Plugins::Conf
  class UserEncoding < Ricer::Plugin
    
    trigger_is :encoding
    
    has_priority 3 # We are called almost first
    
    has_usage :execute_show
    has_usage :execute_show, '<user>'

    has_usage :execute_set, '<encoding>'
    has_usage :execute_set_user, '<user> <encoding>', permission: :ircop
    
    def execute_show(user=nil)
      user ||= sender
      have = user.encoding || user.server.encoding
      rply(:msg_show,
        iso: have.to_label,
        user: user.displayname,
      )
    end

    def execute_set(encoding)
      execute_set_user(sender, encoding)
    end
    
    def execute_set_user(user, encoding)
      have = user.encoding || user.server.encoding
      user.encoding = encoding
      user.save!
      rply(:msg_set,
        :user => user.displayname,
        :old => have.to_label,
        :new => encoding.to_label,
      )
    end
    
    # When we receive a privmsg, we set the encoding to user encoding or server encoding
    def on_privmsg
      begin
        user.localize!
        encoding = user.encoding || server.encoding
        args[1].force_encoding(encoding.to_label)
      rescue StandardError => e
        bot.log_exception(e)
      end
    end

  end
end
