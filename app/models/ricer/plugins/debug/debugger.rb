module Ricer::Plugins::Debug
  class Debugger < Ricer::Plugin
    
    trigger_is :byebug
    permission_is :responsible
    
    has_usage :execute, '<..code..>'
    def execute(code)
      
      byebug
      reply eval(code).inspect
      
    end
    
  end
end
