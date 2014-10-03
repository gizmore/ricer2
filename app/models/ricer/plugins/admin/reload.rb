module Ricer::Plugins::Admin
  class Reload < Ricer::Plugin

    trigger_is :reload
    permission_is :responsible

    has_usage
    def execute
#      rply :msg_reloading # FIXME: This causes a bug because sendqueue is done after reloading...
      clear_plugin_class_variables
      reload_core
      bot.load_plugins(true)
      rply :msg_reloaded
    end
    
    private
    
    def clear_plugin_class_variables
      bot.plugins.each do |plugin|
        Ricer::Plugin.clear_registered_instance_variables.each do |varname|
          plugin.instance_variable_set(varname, nil)
        end
        Ricer::Plugin.registered_class_variables.each do |varname|
          if plugin.class.instance_variable_defined?(varname)
            plugin.class.remove_instance_variable(varname)
          end
        end
      end
      Ricer::Plugin.clear_registered_instance_variables
      Ricer::Plugin.clear_registered_class_variables
    end
    
    def reload_core
      reload_dir 'app/models/ricer/net'
      reload_dir 'app/models/ricer/irc'
      reload_dir 'app/models/ricer/plug'
      bot.load_extenders
    end

    def reload_dir(dirname)
      Dir["#{dirname}/*"].each do |path|
        if File.file?(path)
          if path.end_with?('.rb')
            begin
              load path
            rescue StandardError => e
              bot.log_exception(e)
            end
          end
        else
          reload_dir(path)
        end
      end
    end
    
  end
end
