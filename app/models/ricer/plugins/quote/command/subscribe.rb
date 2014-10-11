module Ricer::Plugins::Quote
  class Subscribe < Ricer::Plugin

    is_announce_trigger :subscribe

    # Static subscribe
    subscribe('ricer/quote/added') do |quote|
      # Get instance and do it
      bot.get_plugin('Quote/Subscribe').announce_quote(quote)
    end

    # Instance does it
    def announce_quote(quote)
      announce_targets do |target|
        unless target == current_message.reply_target
          target.localize!.send_message(announce_message(quote))
        end
      end
    end

    def announce_message(quote)
      t(:msg_announce,
        id: quote.id,
        user: sender.displayname,
        channel: channel.displayname,
        message: quote.message,
      )
    end

  end
end
