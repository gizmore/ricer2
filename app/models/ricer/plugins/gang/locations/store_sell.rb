module Ricer::Plugins::Gang
  class Locations::StoreSell; end
  class Commands::StoreSell < Command
    
    trigger_is :s
    has_usage '<item>'
    def execute
      
    end
  
  end
  Ricer::Bot::get_plugin('Gang/Gang').klass.add_subcommand(:store_sell)
end
