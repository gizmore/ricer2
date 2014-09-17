module Ricer::Plugins::Debug
  class Dbglog < Ricer::Plugin
    
    trigger_is :debuglog
    permission_is :responsible
    
    has_usage '<boolean>'
    def execute(bool)
      Ricer::Application.config.chop_sticks = bool
      if bool; rply :msg_on
      else; rply :msg_off
      end
    end

  end
end
