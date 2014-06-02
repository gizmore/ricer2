module Ricer::Plugins::Stats
  class Version < Ricer::Plugin
    
    trigger_is :version
    
    has_setting name: :owner, type: :string, scope: :bot, permission: :responsible, :default => 'gizmore'
    
    has_usage
    def execute
      rply :version, owner:get_setting(:owner), version:bot.version, builddate:bot.builddate, ruby:RUBY_VERSION, os:os_signature, time:localtime
    end
    
    private
    
    def os_signature
      puts RbConfig::CONFIG.inspect      
      'Linux'
    end
    
    def localtime
      I18n.l(Time.now)
    end
    
  end
end
