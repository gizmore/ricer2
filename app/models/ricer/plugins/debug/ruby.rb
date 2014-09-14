module Ricer::Plugins::Debug
  class Ruby < Ricer::Plugin
    
    trigger_is :ruby
    permission_is :responsible
    
    has_usage '<..code..>'
    def execute(code)
      reply eval(code).inspect
    end

  end
end
