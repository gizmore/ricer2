module Ricer::Plugins::Quote
  class Add < Ricer::Plugin
    
    trigger_is :add
#   scope_is :channel
    permission_is :voice
    
    has_usage :execute, '<..message..>'

    def execute(text)
      quote = Ricer::Plugins::Quote::Model::Quote.create!({
        user: user,
        channel: channel,
        message: text,
      })
      rply :msg_added, :quote_id => quote.id
    end
    
  end
end
