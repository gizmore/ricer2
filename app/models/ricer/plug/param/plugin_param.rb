module Ricer::Plug::Param
  class PluginParam < Base
    def self.get_arg(server, arg, message)
      back = Ricer::Plugin.by_arg(arg)
      back.message = message unless back.nil?
      back
    end
  end
end
