module Ricer::Plugins::Beer
  class Refill < Ricer::Plugin
    
    trigger_is :refill
    
    scope_is :channel
    
    def beer_plugin
      get_plugin('Beer/Beer')
    end
    has_usage :execute_refill, ''
    def execute_refill
      beer_plugin.set_setting(:beer_left, beer_plugin.chest_max)
      rply :msg_refilled, hero: sender, left: beer_plugin.beer_left_text
    end
    
  end
end
