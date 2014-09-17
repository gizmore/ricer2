module Ricer::Plugins::Hacker
  class Jhype < Ricer::Plugin
    
    require 'net/http'
    
    DIR = 'http://sabrefilms.co.uk/store/'

    trigger_is :jhype

    has_setting name: :stocksize, scope: :bot, permission: :responsible, type: :integer, default: 0

    def ricer_on_global_startup
      Ricer::Thread.execute do |t|
        loop {
          begin
            check_for_new_pictures
            sleep(6.hours)
          rescue => e
            bot.log_exception(e)
          end
        }
      end
    end
    
    def check_for_new_pictures
      amt = get_setting(:stocksize)
      uri = URI(DIR)
      http = Net::HTTP.new(uri.host, uri.port)
      while true
        amt += 1
        jlink = jlink(amt)
        uri = URI(jlink)
        response = http.request Net::HTTP::Head.new(uri)
        if response.code == '200'
          announce(jlink)
          save_bot_setting(:stocksize, amt)
        else
          break
        end
      end
    end
    
    def announce(jlink)
      get_plugin('Hacker/JhypeAnnounce').announce_targets do |target|
        target.localize!.send_privmsg(t(:announce, link: jlink))
      end
    end
    
    def jlink(num)
      "#{DIR}j#{num}.jpg"
    end
    
    has_usage :execute_jhype, '<id>'
    has_usage :execute_jhype
    def execute_jhype(num=nil)
      amt = get_bot_setting(:stocksize)
      return rply :err_none if amt == 0
      num = rand(1..amt) if num.nil?
      return show_help unless num.between?(1, amt)
      rply :show, num: num, of: amt, link: jlink(num)
    end
    
  end
end
