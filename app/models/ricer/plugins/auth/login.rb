module Ricer::Plugins::Auth
  class Login < Ricer::Plugin

    trigger_is :login  
    connector_is :irc
    permission_is :registered
    scope_is :user

    bruteforce_protected
    
    has_usage '<password>'
    def execute(password)
      return rply :err_already_authenticated if user.authenticated?
      return rplyp :err_wrong_password unless user.authenticate!(password)
      process_event('ricer_on_user_authenticated')
      rply :msg_authenticated
    end
  
  end
end
