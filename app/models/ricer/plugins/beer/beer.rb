module Ricer::Plugins::Beer
  class Beer < Ricer::Plugin
    
    trigger_is :beer
    
    scope_is :channel
    
    has_setting name: :beer_left, type: :integer, scope: :channel, permission: :responsible, min: 0, max: 100, default: 100
    has_setting name: :chest_max, type: :integer, scope: :channel, permission: :operator,    min: 0, max: 100, default: 24
     
    has_usage :execute_fetch_one, ''
    def execute_fetch_one
      return beer_alert if beer_empty?
      arply(:msg_give_beer, drinker: drinker.displayname, left: beer_left)
    end

    has_usage :execute_give_beer, '<channel_user>'
    def execute_give_beer(drinker)
      return execute_fetch_one if drinker == sender
      return beer_alert if beer_empty?
      return beer_stolen! if beer_stolen?
      arply(:msg_give_beer, giver: sender.displayname, drinker: drinker.displayname, left: beer_left)
    end

    def beer_alert
      reply t(:err_beer_alert).sample
    end
    
    def beer_stolen?
      return false if channel.users.online.human.count == 0
      bot.rand.rand(0..100) < 5
    end
    
    def beer_stolen!(drinker)
      stealers = []
      channel.users.online.human.all.each do |user|
        if (user != sender) && (user != drinker)
          stealers.push(user)
        end 
      end
      arply :msg_stolen, stealer: stealers.sample.displayname, drinker: drinker.displayname, left: beer_left_text 
    end
    
    def beer_left_text
      tp(:left, count: beer_left)
    end
    
    def beer_left
      get_setting(:beer_left)
    end

    def chest_max
      get_setting(:chest_max)
    end
    
    def beer_empty?
      beer_left <= 0
    end
    
    
  end
end
