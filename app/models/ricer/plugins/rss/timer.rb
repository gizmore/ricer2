module Ricer::Plugins::Rss
  class Timer
    
    def bot
      Ricer::Bot.instance      
    end
    
    def start(plugin)
      Ricer::Thread.execute do
        while true
          begin
            check_feeds(plugin)
          rescue StandardError => e
            bot.log_exception e
          end
          sleep(120)
        end
      end
    end
    
    def check_feeds(plugin)
      Feed.all.enabled.each do |feed|
        begin
          feed.check_feed(plugin)
          sleep(3)
        rescue StandardError => e
          bot.log_exception e
        end
      end
    end
    
  end
end
