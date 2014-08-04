module Ricer::Plug::Extender::HasSubcommand
  def has_subcommand(plugin_name)
    class_eval do |klass|
      
      Ricer::Plugin.register_class_variable('@parent_command')
      Ricer::Plugin.register_class_variable('@subcommands')
      Ricer::Plugin.register_class_variable('@subcommand_names')
      Ricer::Plugin.register_class_variable('@subcommand_depth')

      # Append to subcommands
      commands = klass.instance_variable_defined?('@subcommand_names') ? klass.instance_variable_get('@subcommand_names') : []
      commands.push(plugin_name)
      klass.instance_variable_set('@subcommand_names', commands)
      klass.instance_variable_set('@subcommand_depth', 1)
      klass.instance_variable_set('@subcommands', [])
      
      def is_subcommand?
        subcommand_depth > 1
      end

      def has_subcommands?
        subcommands.length > 0
      end
      
      def subcommand_names
        self.class.instance_variable_get('@subcommand_names')
      end

      def subcommands
        self.class.instance_variable_get('@subcommands')
      end
      
      def add_subcommand(plugin)
        plugin.increase_subcommand_depth
        plugin.class.instance_variable_set('@parent_command', self)
        subcommands.push(plugin)
        bot.log_info "Added subcommand to '#{self.short_class_name}': '#{plugin.short_class_name}'."
      end
      
      def show_help
        return show_usage if has_usage?
        return reply 'test'
      end
      
    end
  end
end
