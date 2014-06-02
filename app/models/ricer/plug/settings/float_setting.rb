module Ricer::Plug::Settings
  class FloatSetting < IntegerSetting
    
    def self.to_value(input)
      input.to_f rescue nil
    end
    
    def self.to_hint(options={})
      I18n.t('ricer.plug.settings.hint.float', min: min(options), max: max(options))
    end
    
  end
end
