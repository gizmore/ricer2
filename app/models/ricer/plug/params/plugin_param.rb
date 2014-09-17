module Ricer::Plug::Params
  class PluginParam < Base

    def convert_in!(input, message)
      Ricer::Plugin.by_arg(input) or failed_input
    end

    def convert_out!(plugin, message)
      plugin.plugin_name
    end

  end
end
