module Ricer::Plug::Settings
  class DatetimeSetting < Base
    
    def self.to_value(input)
      return input if input.is_a?(DateTime)
      DateTime.parse(input)
    end
    
    def self.db_value(input)
      input.to_s
    end
    
    def self.to_label(input)
      I18n.l(input)
    end
    
    def self.to_hint(options={})
      I18n.t('ricer.plug.settings.hint.datetime')
    end
    
  end
end
