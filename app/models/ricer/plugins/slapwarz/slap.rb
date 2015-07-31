module Ricer::Plugins::Slapwarz
  class Slap < Ricer::Plugin
    
    trigger_is :slap
        
    has_usage '<user[online=1]>'
    def execute(user)
      byebug
      puts user
      byebug
    end
    
  end
end