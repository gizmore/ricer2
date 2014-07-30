module Ricer::Plugins::Conf
  class Enable < Ricer::Plugin
    
    trigger_is :enable
    
    has_usage :execute_server, '<trigger>', :scope => :user, :permission => :owner
    def execute_server(plugin)
      exec("confs #{plugin} trigger_enabled 1")
    end

    has_usage :execute_channel, '<trigger>', :scope => :channel, :permission => :operator
    def execute_channel(plugin)
      exec("confc #{plugin} trigger_enabled 1")
    end

  end
end
