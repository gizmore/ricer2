module Ricer::Plugins::Debug
  class Console < Ricer::Plugin
    
    trigger_is :console
    permission_is :responsible
    
    has_usage :execute, '<..code..>'
    def execute(code)
      eval(code)
    end

  end
end
