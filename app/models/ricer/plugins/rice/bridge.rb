module Ricer::Plugins::Rice
  class Bridge < Ricer::Plugin
    
    has_priority 1

    def core_plugin?; true; end

  end
end
