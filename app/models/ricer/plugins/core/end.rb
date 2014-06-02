module Ricer::Plugins::Core
  class End < Ricer::Plugin
    
    trigger_is :end
    permission_is :voice
    has_priority 2

    has_usage
    def execute
      byebug
      get_plugin('Core/Begin').finish
    end
    
  end
end
