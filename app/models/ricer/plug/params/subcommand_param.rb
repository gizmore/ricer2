module Ricer::Plug::Params
  class SubcommandParam < Base
    
    def param_subcommand
      bot.get_plugin(options[:module]) || failed_input
    end

    def convert_in!(input, message)
      param_subcommand.subcommand_by_arg(input) || failed_input
    end

    def convert_out!(plugin, message)
      plugin.plugin_name
    end

  end
end
