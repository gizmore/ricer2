module Ricer::Plugins::Purple
  class Violet < Ricer::Plugin
    
    connector_is :purple

    def priority; 0; end 
    def core_plugin?; true; end
    
    def on_privmsg
      puts "PURPLE CAN RICER2!"
      byebug
    end

  end
end
