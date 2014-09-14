module Ricer::Plugins::Debug
  class Plugdebug < Ricer::Plugin
    
    trigger_is :pdbg
    permission_is :operator

    has_usage '<plugin>'
    def execute(plugin)
      rply(:msg_plug_info,
        modulename: plugin.plugin_module,
        classname: plugin.class.name,
        path: plugin.plugin_path,
        trigger: plugin.trigger,
        plugscope: plugin.scope.to_label,
        permission: plugin.trigger_permission.to_label,
      )
    end
    
  end
end
