module Ricer::Plug::Params
  class PermissionParam < Base
    
    def convert_in!(input, message)
      permission = Ricer::Irc::Permission.by_name(input)
      failed_input if permission.nil?
      permission
    end
    def convert_out!(value, message)
      value.to_label
    end
    
  end
end
