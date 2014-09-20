module Ricer::Plugins::Core
  class Outfile < Ricer::Plugin

    trigger_is :outfile

    has_usage '<filename>'
    def execute(filename)
      reply filename
    end
    
  end
end
