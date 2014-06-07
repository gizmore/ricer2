module Ricer::Plug::Params
  class PermissionParam < Base
    
    def convert_in!(input, options, message)
      permission = Ricer::Irc::Permission.by_name(input)
      failed_input if permission.nil?
      permission
    end
    def convert_out!(value, options, message)
      value.to_label
    end
    
  end
end
