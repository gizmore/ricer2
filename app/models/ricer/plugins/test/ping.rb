module Ricer::Plugins::Test
  class Ping < Ricer::Plugin
    
    trigger_is :ping

    # Plugin var that has bot scope (global)    
    has_setting name: :count, type: :integer, scope: :bot, permission: :responsible, default: 0
    
    # Static var that is reset on reload
    def on_init
      @@count = 0
    end
  
    # Calls execute ping without args, and allows garbage after parsing is done  
    has_usage :execute_ping, '', :allow_trailing => true
    def execute_ping
      # Print out and increase both
      @@count += 1
      rply :pong, :count => @@count, :global => increase_setting(:count, :bot)
    end

  end
end
