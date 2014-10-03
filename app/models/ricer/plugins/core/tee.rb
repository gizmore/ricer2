module Ricer::Plugins::Core
  class Tee < Ricer::Plugin
    
    trigger_is :tee
    permission_is :responsible
    
    has_usage '<target[online=1]> <..text..>'
    def execute(targets, text)
      targets.each do |target|
        target.send_message(text)
      end
    end

  end
end
