module Ricer::Plugins::Seen
  class Seen < Ricer::Plugin
    
    trigger_is :seen
    
    def upgrade_1; Entry.upgrade_1; Said.upgrade_1; end
    
    has_usage '<user>'
    has_usage '<user> <boolean>'
    def execute(user, last_privmsg=true)
      klass = last_privmsg ? Said : Entry
      entry = klass.for_user(user)
      return rply :err_nothing unless entry
      rply :msg_seen
    end
    
    
  end
end