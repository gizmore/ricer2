module Ricer::Plugins::Test
  class Disabled < Ricer::Plugin
    
    # has_license  :mit
    # developed_by :gizmore
    
    trigger_is     'disabled'
    permission_is  :moderator
    scope_is       :channel
    
    default_enabled    false
    has_description    {en:'Test default disabled', de:'Default disabled testen'}
    
    has_usage  :execute_one_arg, '<user>'
    has_usage  :execute_with_multiline, '<user> [<..message..>]'
    has_usage  :execute # Fallback
    has_usage # same
    
    def execute_one_arg
       execute
    end
    
    def execute_with_multiline
      execute
    end
    
    def execute
      reply 'Should not see me'
    end
    
  end
end
