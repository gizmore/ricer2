module Ricer::Plugins::Auth
  class Register < Ricer::Plugin
    
    trigger_is :register
    connector_is :irc
    scope_is :user

    bruteforce_protected :always => false
    
    has_usage :register, '<password>'
    def register(password)
      return rply :err_already_registered if user.registered?
      user.password = password
      user.save!
      user.login!
      rply :msg_registered
      server.process_event('ricer_on_user_registered', current_message)
    end
    
    has_usage :change_password, '<password> <password>'
    def change_password(new_password, old_password)
      bruteforcing?
      return rplyp :err_wrong_password unless user.authenticate!(old_password)
      user.password = new_password
      user.save!
      user.login!
      rply :msg_changed_pass
    end
    
  end
end
