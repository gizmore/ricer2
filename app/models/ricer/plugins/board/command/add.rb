module Ricer::Plugins::Board
  class Add < Ricer::Plugin
    
    trigger_is :add
    permission_is :owner
    
    has_usage '<url>'

    def execute(url)
      byebug
    end
    
  end
end
