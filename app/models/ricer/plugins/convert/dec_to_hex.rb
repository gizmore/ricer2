module Ricer::Plugins::Convert
  class DecToHex < Ricer::Plugin

    trigger_is :dec2hex

    has_usage '<..numbers..>'
    def execute(numbers)
      get_plugin('Convert/Base').execute(10, 16, numbers)
    end

  end
end
