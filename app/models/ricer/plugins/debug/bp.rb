module Ricer::Plugins::Debug
  class Bp < Ricer::Plugin
    
    trigger_is :bp
    permission_is :responsible
    
    has_usage :execute, '<..command..>'
    def execute(command)
      byebug # Breakpoint :)
      exec_line command
    end
    
  end
end