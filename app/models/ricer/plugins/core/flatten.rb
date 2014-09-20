module Ricer::Plugins::Core
  class Flatten < Ricer::Plugin

    trigger_is :flatten

    has_usage '<..text..>'
    def execute(lines)
      comma = lib.comma
      reply Array(lines).join(comma).gsub("\n", comma)
    end
    
  end
end
