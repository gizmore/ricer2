module Ricer::Plugins::Conf
  class Enable < Ricer::Plugin
    
    trigger_is :enable
    always_enabled
    
    has_usage :execute_server, '<trigger>', :scope => :user, :permission => :owner
    def execute_server(plugin)
      get_plugin('Conf/ConfServer').set_var(plugin, :trigger_enabled, true)
    end

    has_usage :execute_channel, '<trigger>', :scope => :channel, :permission => :operator
    def execute_channel(plugin)
      get_plugin('Conf/ConfChannel').set_var(plugin, :trigger_enabled, true)
    end

  end
end
