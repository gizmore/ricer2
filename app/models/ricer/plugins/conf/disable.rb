module Ricer::Plugins::Conf
  class Disable < Ricer::Plugin
    
    trigger_is :disable
    always_enabled
    
    has_usage :execute_server, '<plugin>', :scope => :user, :permission => :owner
    def execute_server(plugin)
      get_plugin('Conf/ConfServer').set_var(plugin, :trigger_enabled, false)
    end

    has_usage :execute_channel, '<plugin>', :scope => :channel, :permission => :operator
    def execute_channel(plugin)
      get_plugin('Conf/ConfChannel').set_var(plugin, :trigger_enabled, false)
    end

  end
end
