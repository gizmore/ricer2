module Ricer::Plug::Extender::HasSubcommandHelp
  
  OPTIONS = {
    trigger: :help
  }
  
  def has_subcommand_help(options={})
    class_eval do |klass|

      options.reverse_merge!({trigger: :help})
    
      throw "Plugin #{klass.name} has_subcommand_help but does not specify a module: #{options[:module]}" unless options[:module]
      
      # We are a trigger
      klass.trigger_is options[:trigger]

      # And remember module
      klass.register_class_variable(:@subcommand_help_module)
      klass.instance_variable_set(:@subcommand_help_module, options[:module])
      
      ####################
      ### ParentPlugin ###
      ####################
      def help_module
        bot.get_plugin(help_module_name) or
          raise "#{plugin_name} cannot find it´s module."
      end

      def help_module_name
        self.class.instance_variable_get(:@subcommand_help_module)
      end
      
      def help_subcommands
        help_module.subcommands
      end
      
      #################
      ### Executors ###
      #################
      klass.has_usage :execute_subcommand_list
      def execute_subcommand_list
        out = help_subcommands.collect{|command|command.trigger}
        reply tt("ricer.plug.extender.has_subcommand_help.msg_list", commands: lib.join(out))
      end
      
      klass.has_usage :execute_subcommand_help, "<subcommand[module=#{options[:module]}]>"
      def execute_subcommand_help(plugin)
        reply plugin.show_help
      end
      
    end
  end
end
