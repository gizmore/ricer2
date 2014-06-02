module Ricer::Plugins::Conf
  class Help < Ricer::Plugin
    
    trigger_is :help
    
    bruteforce_protected :always => false
    
    has_usage :execute_help, '<trigger>'
    has_usage :execute_list, ''
    
    def execute_help(trigger)
      return trigger.show_help
    end
        
    def execute_list
      return if bruteforcing?
      grouped = collect_groups
      grouped = Hash[grouped.sort]
      grouped.each do |k,v|; grouped[k] = v.sort; end
      nrplyp :msg_triggers, :triggers => grouped_output(grouped)
    end


    protected
    
    def help_plugins
      triggers = []
      Ricer::Bot.instance.plugins.each do |plugin|
        triggers.push(plugin) if plugin.has_usage?
      end
      triggers
    end
    
    private
    
    def collect_groups()
      grouped = {}
      help_plugins.each do |plugin|
        plugin.message = @message
        if plugin.in_scope? && plugin.has_permission?
          m = plugin.plugin_module
          grouped[m] = [] if grouped[m].nil?
          grouped[m].push(plugin.trigger)
        end
      end
      grouped
    end
    
    def grouped_output(grouped)
      out = []
      grouped.each do |k,v|
        group = bold(k) + ': '
        group += v.join(', ')
        out.push(group)
      end
      out.join('. ')
    end
    
  end

end
