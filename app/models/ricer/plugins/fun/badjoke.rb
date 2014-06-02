module Ricer::Plugins::Fun
  class Badjoke < Ricer::Plugin
    
    trigger_is :badjoke
    
    has_usage
    def execute
      case rand(2)
      when 0; rply :badum
      when 1; arply :cricket
      when 2; arply :tumbleweed
      end
    end
    
  end
end
