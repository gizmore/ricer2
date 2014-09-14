module Ricer::Plug::Params
  class SubcommandParam < Base
    
    def param_subcommand
      bot.get_plugin(options[:module]) || failed_input
    end

    def convert_in!(input, message)
      plugin = param_subcommand.subcommand_by_arg(input) || failed_input
      plugin.message = message and return plugin
    end

    def convert_out!(plugin, message)
      plugin.plugin_name
    end

  end
end
