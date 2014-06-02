module Ricer::Plugins::Channel
  class Part < Ricer::Plugin
    
    trigger_is :part
    permission_is :operator
    scope_is :channel
    
    has_usage
    def execute
      get_plugin('Channel/Partu').execute(channel)
    end
    
  end
end
