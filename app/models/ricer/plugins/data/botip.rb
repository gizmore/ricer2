require "open-uri"

module Ricer::Plugins::Data
  class Botip < Ricer::Plugin

    trigger_is :botip

    has_usage :execute

    def execute
      Ricer::Thread.execute do
        ip = open("http://ipecho.net/plain")
        response = ip.read
        reply response
      end
    end
  end
end
