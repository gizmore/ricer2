module Ricer::Plugins::Admin
  class Reload < Ricer::Plugin

    trigger_is :reload
    permission_is :responsible

    has_usage
    def execute
      rply :msg_reloading
      clear_plugin_class_variables
      reload_core
      bot.load_plugins(true)
      rply :msg_reloaded
    end
    
    private
    
    def clear_plugin_class_variables
      bot.plugins.each do |plugin|
        Ricer::Plugin.registered_class_variables.each do |varname|
          plugin.class.remove_instance_variable(varname) if instance_variable_defined?(varname)
        end
      end
      Ricer::Plugin.clear_registered_class_variables
    end
    
    def reload_core
      reload_dir 'app/models/ricer/net'
      reload_dir 'app/models/ricer/irc'
      reload_dir 'app/models/ricer/plug'
    end

    def reload_dir(dirname)
      Dir["#{dirname}/*"].each do |path|
        if File.file?(path)
          if path.end_with?('.rb')
            begin
              load path
            rescue => e
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
