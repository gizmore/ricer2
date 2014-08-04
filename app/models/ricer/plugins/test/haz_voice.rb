module Ricer::Plugins::Test
  class HazVoice < Ricer::Plugin
    
    trigger_is 'hazivoice?'

    permission_is :voice

    has_usage
    def execute
      rply :msg_yes
    end

  end
end
