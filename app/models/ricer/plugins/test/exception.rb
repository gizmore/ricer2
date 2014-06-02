module Ricer::Plugins::Test
  class Exception < Ricer::Plugin
    
    trigger_is :fatal

    permission_is :responsible

    has_usage

    def execute
      byte.ist.doof
    end

  end
end
