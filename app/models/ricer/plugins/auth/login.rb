module Ricer::Plugins::Auth
  class Login < Ricer::Plugin

    trigger_is :login  
    scope_is :user
    permission_is :registered
    
    connector_is :irc

    bruteforce_protected

    has_usage :execute, '<password>' 
    def execute(password)
      return rply :err_already_authenticated if user.authenticated?
      return rplyp :err_wrong_password unless user.authenticate!(password)
      process_event('ricer_on_user_authenticated')
      rply :msg_authenticated
    end
  
  end
end
