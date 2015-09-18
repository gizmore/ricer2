module Ricer::Plugins::Quote
  class Show < Ricer::Plugin
    
    trigger_is :quote

    has_usage :execute_random, ""
    def execute_random
      execute(Model::Quote.limit(1).offset(bot.rand.rand(1..Model::Quote.count)).first.id)
    end

    has_usage :execute, "<id>"
    def execute(id)
      quote = Model::Quote.find(id)
      reply quote.display_show_item(id)
    end
    
  end
end