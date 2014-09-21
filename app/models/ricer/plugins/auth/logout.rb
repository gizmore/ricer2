module Ricer::Plugins::Auth
  class Logout < Ricer::Plugin
  
    trigger_is :logout
    connector_is :irc
    permission_is :authenticated
    
    has_usage
    def execute
      user.logout!
      rply :msg_logged_out
      process_event('ricer_on_user_logged_out')
    end
  
  end
end
