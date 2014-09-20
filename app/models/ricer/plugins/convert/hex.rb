module Ricer::Plugins::Convert
  class Hex < Ricer::Plugin

    trigger_is :hex

    has_usage '<..text..>'
    def execute(text)
      out = []
      text.each_char do |char|
        out.push(char.unpack('H*')[0])
      end
      reply lib.join(out)
    end

  end
end
