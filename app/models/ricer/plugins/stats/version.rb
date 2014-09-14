module Ricer::Plugins::Stats
  class Version < Ricer::Plugin
    
    trigger_is :version
    
    has_usage
    def execute
      rply :version,
        owner: bot.owner_name,
        version: bot.version,
        builddate: bot.builddate,
        ruby: RUBY_VERSION,
        os: os_signature,
        time: l(Time.now),
        environment: Rails.env
    end
    
    private
    
    def os_signature
      bot.log_debug(RbConfig::CONFIG.inspect)
      'Linux'
    end
    
  end
end
