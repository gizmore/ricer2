module Ricer::Plugins::Convert
  class Urldecode < Ricer::Plugin

    trigger_is :urldecode

    has_usage '<..text..>'
    def execute(text)
      reply URI::decode(text)
    end

  end
end
