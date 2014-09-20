module Ricer
  class PluginMap
    
    include Singleton
    include Ricer::Plug::Extender::KnowsEvents
    
    attr_reader :event_count, :trigger_count
    
    def bot; Ricer::Bot.instance; end
    
    def clear_cache
      @connectors = {}
      @connector_count = 0
      @event_map = {}
      @event_count = 0
      @trigger_count = 0
    end
    
    #############
    ### Stats ###
    #############
    def event_count; @event_count; end
    def event_type_count; @event_map.keys.length; end

    ##################
    ### Connectors ###
    ##################
    def connector_symbols; @connectors.keys; end
    def connector_for(symbol); @connectors[symbol]; end
    def register_connector(symbol, klass)
      @connectors[symbol] = klass
      @connector_count += 1
      
    end
    
    def load_connector(connector)
      register_connector(connector.connector_symbol, connector)
    end
    
    def get_connector(name)
      @connectors[name.to_sym]
    end

    ##############
    ### Events ###
    ##############
    def register_event(event_name, plugin)
      @event_map[event_name.to_sym] ||= []
      @event_map[event_name.to_sym].push(plugin)
      if event_name == 'on_privmsg' && plugin.has_usage?
        @trigger_count += 1
        #bot.log_debug "Mapped trigger #{plugin.plugin_name}"
      else
        @event_count += 1
        #bot.log_debug "Mapped event #{event_name} to #{plugin.plugin_name}"
      end
    end
    
    def load_plugin(plugin)
      plugin.class.instance_methods.each do |method_name|
        m = method_name.to_s
        if m.starts_with?('on_') || m.start_with?('ricer_on_')
          register_event(method_name, plugin)
        end
      end
      # Not in above enumerator without (true); a bit faster unrolled
      #if plugin.has_usage? # respond_to?(:on_privmsg)
      #  register_event(:on_privmsg, plugin)
      #end
    end
    
    def plugins_for_event(event_name)
      @event_map[event_name.to_sym] || []
    end
    
    ############
    ### Sort ###
    ############
    def sort_plugin_map
      @event_map.each{|k,plugins| sort_plugins(plugins) }
    end
    
    def sort_plugins(plugins)
      plugins.sort!{|a,b| a.trigger_permission.bit - b.trigger_permission.bit rescue 0 }
      plugins.sort!{|a,b| b.scope.bit - a.scope.bit }
      plugins.sort!{|a,b| a.subcommand_depth - b.subcommand_depth }
      plugins.sort!{|a,b| a.priority - b.priority }
    end
    
    ##################
    ### After Load ###
    ##################
    def validate_plugins!
      validate_duplicate_triggers!
    end
    
    def validate_duplicate_triggers!
      all_valid = true
      triggers = {}
      bot.plugins.each do |plugin|
        trigger = plugin.trigger
        if triggers[trigger].nil?
          triggers[trigger] = plugin
        else
          bot.log_warn("'#{plugin.class.name}' and '#{triggers[trigger].class.name}', share the same trigger: #{trigger}.")
          all_valid = false and sleep 10.seconds
        end
      end
      all_valid
    end
    
  end
end
