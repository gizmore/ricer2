module Ricer::Plug::Extender::HasSubcommand
  def has_subcommand(plugin_name)
    class_eval do |klass|
      
      klass.register_class_variable('@subcommands')
      klass.register_class_variable('@subcommand_names')
      klass.register_class_variable('@subcommand_depth')
      klass.register_class_variable('@parent_command')

      # Append to subcommands
      commands = klass.instance_variable_define('@subcommand_names', [])
      klass.instance_variable_set('@subcommand_depth', 1)
      klass.instance_variable_set('@subcommands', [])
      commands.push(plugin_name) unless commands.include?(plugin_name)
      
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
        self
      end
      
    end
  end
end
