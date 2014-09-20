module Ricer::Plugins::Core
  class End < Ricer::Plugin
    
    trigger_is :end
    permission_is :voice
    has_priority 8

    has_usage
    def execute
      get_plugin('Core/Begin').finish
    end
    
  end
end
