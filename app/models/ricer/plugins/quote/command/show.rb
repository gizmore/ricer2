module Ricer::Plugins::Quote
  class Show < Ricer::Plugin
    
    trigger_is :quote

    has_usage :execute, "<id>"
    def execute(id)
      quote = Model::Quote.find(id)
      reply quote.display_show_item(id)
    end
    
  end
end