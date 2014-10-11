module Ricer::Plugins::Convert
  class Strlen < Ricer::Plugin

    trigger_is :strlen

    has_usage '<..text..>'
    def execute(text)
      reply text.length
    end

  end
end
