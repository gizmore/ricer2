module Ricer::Plugins::Debug
  class Byebug < Ricer::Plugin
    
    trigger_is :byebug
    permission_is :responsible
    
    has_usage
    def execute
      reply "Launching debugger..."
      byebug
      reply "Welcome back!"
    end
    
  end
end
