module Ricer::Plug::Params
  class PluginParam < Base

    def convert_in!(input, message)
      plugin = Ricer::Plugin.by_arg(input)
      failed_input if plugin.nil?
      plugin.message = message
      plugin
    end

    def convert_out!(value, message)
      value.plugin_name
    end

  end
end
