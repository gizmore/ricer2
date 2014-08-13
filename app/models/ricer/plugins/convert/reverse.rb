module Ricer::Plugins::Convert
  class Reverse < Ricer::Plugin

    trigger_is :reverse

    has_usage :execute_reverse, '<...message...>'
    def execute_reverse(message)
      reply message.reverse
    end

  end
end
