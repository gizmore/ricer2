module Ricer::Plugins::Convert
  class Reverse < Ricer::Plugin

    trigger_is :reverse

    has_usage '<..text..>'
    def execute(text)
      reply text.reverse
    end

  end
end
