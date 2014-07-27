module Ricer::Plugins::Stats
  class Stats < Ricer::Plugin

    trigger_is :stats
        
    has_usage
    def execute
      rply :stats,
        active_servers: Ricer::Irc::Server.online.count,
        total_servers: Ricer::Irc::Server.count,
        channels: Ricer::Irc::Channel.online.count,
        users: Ricer::Irc::User.online.count,
        plugins: bot.plugins.count,
        events: Ricer::PluginMap.instance.event_count
    end

  end
end
