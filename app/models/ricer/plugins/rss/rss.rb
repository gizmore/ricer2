module Ricer::Plugins::Rss
  class Rss < Ricer::Plugin
    
    has_subcommand :add
    has_subcommand :abbo
    has_subcommand :abbos
    has_subcommand :unabbo

    def upgrade_1
      Feed.upgrade_1
    end

    def ricer_on_global_startup
      Ricer::Plugins::Rss::Timer.new.start(self)
    end

  end
end
