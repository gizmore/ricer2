module Ricer::Plugins::Debug
  class Railsc < Ricer::Plugin
    
    trigger_is :rails
    permission_is :responsible
    
    has_usage :execute, '<..code..>'
    def execute(code)
      reply eval(code).inspect
    end

  end
end
