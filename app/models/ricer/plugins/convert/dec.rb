module Ricer::Plugins::Convert
  class Dec < Ricer::Plugin

    trigger_is :dec

    has_usage '<..text..>'
    def execute(text)
      out = []
      text.each_char do |char|
        out.push(char.unpack('C')[0])
      end
      reply lib.join(out)
    end

  end
end
