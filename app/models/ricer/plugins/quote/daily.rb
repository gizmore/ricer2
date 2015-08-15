module Ricer::Plugins::Quote
  class Daily < Ricer::Plugin
    
    trigger_is :dailyquote

    has_setting name: :dailyquote, type: :boolean, scope: :user,    permission: :registered, default: false 
    has_setting name: :dailyquote, type: :boolean, scope: :channel, permission: :halfop,     default: false
    
    def ricer_on_global_startup
      sleep 42.seconds
      Ricer::Thread.execute {
        loop {
          announce_quote
          sleep(1.hour)
        }
      }
    end
    
    def announce_quote
      if quote = quote_of_the_hour
        channels_with_setting(:dailyquote, true).each do |channel|
          announce_quote_to(quote, channel)
        end
        users_with_setting(:dailyquote, true).each do |user|
          announce_quote_to(quote, user)
        end
      end
    end
    
    def announce_quote_to(quote, to)
      to.localize!.send_privmsg(announcement(quote)) if to.online?
    end
    
    def announcement(quote)
      t(:announcement, quote: quote.display_show_item)
    end
    
    def quote_of_the_hour
      Model::Quote.offset(rand(Model::Quote.count)).first
    end

  end
end
