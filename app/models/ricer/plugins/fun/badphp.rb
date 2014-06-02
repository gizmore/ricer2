module Ricer::Plugins::Fun
  class Badphp < Ricer::Plugin
    
    trigger_is :badphp
    permission_is :voice
    
    has_usage
    def execute
      reply description
    end
    
  end
end
