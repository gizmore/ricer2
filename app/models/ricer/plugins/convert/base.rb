module Ricer::Plugins::Convert
  class Base < Ricer::Plugin

    trigger_is :base

    has_usage '<integer[min=2,max=64]> <integer[min=2,max=64]> <..text..>'
    def execute(inbase, tobase, numbers)
    end

  end
end
