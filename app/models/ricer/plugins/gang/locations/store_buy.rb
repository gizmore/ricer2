module Ricer::Plugins::Gang
  class Locations::StoreBuy; end
  class Commands::StoreBuy < Command
    
    trigger_is :b
    has_usage '<store_item>'
    def execute()
      
    end
  
  end
  Ricer::Bot::get_plugin('Gang/Gang').klass.add_subcommand(:store_sell)
end
