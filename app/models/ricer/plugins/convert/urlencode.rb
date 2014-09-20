module Ricer::Plugins::Convert
  class Urlencode < Ricer::Plugin

    trigger_is :urlencode

    has_usage '<..text..>'
    def execute(text)
      byebug
      reply URI::encode(text)
    end

  end
end
