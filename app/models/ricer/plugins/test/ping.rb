module Ricer::Plugins::Test
  class Ping < Ricer::Plugin
    
    trigger_is :ping
    
    has_setting name: :count, type: :integer, scope: :bot, permission: :responsible, default: 0
    
    def on_init
      @@count = 0
    end
    
    has_usage
    def execute
      @@count += 1
      rply :pong, :count => @@count, :global => increase_setting(:count, :bot)
    end

  end
end
