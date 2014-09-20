module Ricer::Plugins::Convert
  class Decode < Ricer::Plugin

    trigger_is :decode

    has_usage '<encoding> <..string..>'
    def execute(encoding, string)
      reply string.force_encoding(encoding.to_label)
    end

  end
end
