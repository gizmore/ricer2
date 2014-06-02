module Ricer::Plug::Settings
  class PermissionSetting < Base
    
    def self.to_value(input)
      Ricer::Irc::Permission.by_arg(input)
    end
    
    def self.db_value(input)
      input.name.to_s
    end
    
    def self.to_label(input)
      input.to_label
    end
    
    def self.to_hint(options={})
      I18n.t('ricer.plug.settings.hint.permission')
    end
    
  end
end
