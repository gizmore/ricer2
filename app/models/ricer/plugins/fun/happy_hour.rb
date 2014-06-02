module Ricer::Plugins::Fun
  class HappyHour < Ricer::Plugin
    
    trigger_is :happy_hour
    permission_is :responsible

    has_usage
    def execute
      reply 'https://www.youtube.com/watch?feature=player_detailpage&v=E0Mi1ANe79o#t=527s'
    end
    
  end
end
