module Ricer::Plug::Params
  class PluginParam < Base

    def convert_in!(input, options, message)
      plugin = Ricer::Plugin.by_arg(input)
      failed_input if plugin.nil?
      plugin.message = message
      plugin
    end

    def convert_out!(value, options, message)
      value.plugin_name
    end

  end
end
