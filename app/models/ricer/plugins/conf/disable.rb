module Ricer::Plugins::Conf
  class Disable < Ricer::Plugin
    
    trigger_is :disable
    
    has_usage :execute_server, '<plugin>', :scope => :user, :permission => :owner
    def execute_server(plugin)
      exec("confs #{plugin} trigger_enabled 0")
    end

    has_usage :execute_channel, '<plugin>', :scope => :channel, :permission => :operator
    def execute_channel(plugin)
      exec("confc #{plugin} trigger_enabled 0")
    end

  end
end
