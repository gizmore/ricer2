module Ricer::Plugins::Stats
  class Stats < Ricer::Plugin

    trigger_is :stats

    has_setting name: :uptime, scope: :bot, type: :duration, permission: :responsible, default: 0
    
    def ricer_on_global_exit
      increase_setting(:uptime, :bot, bot.uptime)
      bot.log_debug("Stats/Perf increases total_uptime by #{bot.uptime.to_f} is now: #{show_bot_setting(:uptime)}")
    end

    def total_uptime
      get_bot_setting(:uptime) + bot.uptime
    end
    
    has_usage
    def execute
      rply(:stats,
        active_servers: Ricer::Irc::Server.online.count,
        total_servers: Ricer::Irc::Server.count,
        channels: Ricer::Irc::Channel.online.count,
        users: Ricer::Irc::User.online.count,
        plugins: bot.plugins.count,
        events: Ricer::PluginMap.instance.event_count,
        uptime: lib.human_duration(bot.uptime),
        runtime: lib.human_duration(total_uptime),
      )
    end

  end
end
