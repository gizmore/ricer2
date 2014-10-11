module Ricer::Plugins::Quote
  class Add < Ricer::Plugin

    trigger_is :add

    scope_is :channel
    permission_is :voice

    has_usage '<..text..>'
    def execute(text)
      # Try to kill the database with fire.
      quote = Ricer::Plugins::Quote::Model::Quote.create!({
        user: user,
        channel: channel,
        message: text,
      })
      # Use publish/subscribe to react on new quotes.
      publish('ricer/quote/added', quote)
      # We are done :)
      rply :msg_added, :quote_id => quote.id
    end

  end
end
