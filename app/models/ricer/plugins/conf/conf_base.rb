module Ricer::Plugins::Conf
  class ConfBase < Ricer::Plugin
  
    def description; tt("ricer.plugins.conf.conf.description"); end
    
    def config_channel
      channel
    end
  
    def config_settings(plugin)
      back = {}
      plugin.memory_settings.each do |options|
        if Ricer::Irc::Scope.matching?(options[:scope], config_scope, config_channel)
          back[options[:name]] ||= []
          back[options[:name]].push(options)
        end
      end
      back
    end
    
    def conflicting?(settings)
      count = 0
      settings.each do |options|
        count += 1 if Ricer::Irc::Scope.matching?(options[:scope], config_scope, config_channel)
      end
      count != 1
    end
    
    def change_permitted?(setting)
      user.permission.has_permission?(setting.permission)
    end
    
    def msg_no_trigger(plugin)
      rplyp :msg_no_settings, :trigger => plugin.trigger       
    end
    
    def show_vars(plugin)
      settings = config_settings(plugin)
      vars = []
      settings.each do |key,value|
        vars.push("#{key}(#{plugin.scope_setting(config_scope, config_object, key).to_label})")
      end
      return msg_no_trigger(plugin) if settings.empty?
      rplyp :msg_overview, :trigger => plugin.trigger, :vars => vars.join(', ')
    end
    
    def show_all_vars
      
    end
    
    def show_var(plugin, varname)
      settings = config_settings(plugin)[varname]
      return rplyp :err_no_such_var if settings.nil?
      out = ''
      settings.each do |options|
        setting = plugin.scope_setting(options[:scope], config_object, varname)
        b = setting.persisted? ? "\x02" : ''
        out += " #{setting.scope.to_label}=#{b}#{setting.to_label}#{b}"
      end
      setting = plugin.scope_setting(config_scope, config_object, varname)
      out += " = #{setting.to_label}"
      rplyp :msg_show_var, trigger: plugin.trigger, varname: varname, values: out.ltrim, hint: setting.to_hint
    end

    def set_var(plugin, varname, value)
      
      settings = config_settings(plugin)[varname]
      return rplyp :err_no_such_var if settings.nil?
      return rplyp :err_conflicting if conflicting?(settings)

      options = settings[0]
      setting = plugin.scope_setting(options[:scope], config_object, varname)
      
      return rplyp :err_no_such_var if setting.nil?
      return rplyp :err_permission unless change_permitted?(setting)
      return rplyp :err_invalid_value, trigger: plugin.trigger, varname: varname, hint: setting.to_hint unless setting.valid_value?(value)
  
      # No change?
      if setting.equals_input?(value)
        return rplyp(:msg_no_change,
          configscope: setting.scope.to_label,
          trigger: plugin.trigger,
          varname: varname,
          samevalue: setting.to_label
        ) 
      end

      # Save and reply
      old_label = setting.to_label
      setting.save_value(value)
      rplyp :msg_saved_setting,
        configscope: setting.scope.to_label,
        trigger: plugin.trigger,
        varname: varname,
        oldvalue: old_label,
        newvalue: setting.to_label
    end
    
  end
end
