module Ricer::Plugins::Test
  class Timer < Ricer::Plugin

    trigger_is :timertest

    permission_is :responsible
    
    has_usage
    def execute
      Ricer::Thread.execute do
        sleep 5
        rply :timeout
      end
    end
    
  end
end
