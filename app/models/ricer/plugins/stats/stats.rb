module Ricer::Plugins::Stats
  class Stats < Ricer::Plugin

    trigger_is :stats
        
    has_usage
    def execute
      plugins = 0
      events = 0
      # bot.plugins.each do |p|
        # if p.has_usage?
          # plugins += 1
        # end
        # events += p.event_listeners.length
      # end
      rply :stats,
        active_servers: Ricer::Irc::Server.online.count,
        total_servers: Ricer::Irc::Server.count,
        channels: Ricer::Irc::Channel.online.count,
        users: Ricer::Irc::User.online.count,
        plugins: plugins,
        events: events
    end

  end
end
