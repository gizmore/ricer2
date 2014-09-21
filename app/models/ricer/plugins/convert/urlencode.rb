module Ricer::Plugins::Convert
  class Urlencode < Ricer::Plugin

    trigger_is :urlencode

    has_usage '<..text..>'
    def execute(text)
      reply URI::encode(text)
    end

  end
end
