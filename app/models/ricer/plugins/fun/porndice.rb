module Ricer::Plugins::Fun
  class Porndice < Ricer::Plugin
    
    trigger_is    :porndice
    permission_is :responsible
    
    has_usage "<user[online=1]> <gender>"
    def execute(user, gender)
      reply "hi"
      
    end
  end
end
