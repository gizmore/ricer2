module Ricer::Plug::Settings
  class DurationSetting < FloatSetting
    
    def self.db_value(input)
      lib.human_to_seconds(input)
    end
    
    def self.to_label(input)
      lib.human_duration(input)
    end
    
    def self.to_hint(options)
      I18n.t('ricer.plug.settings.hint.duration', min: lib.human_duration(min(options)), max: lib.human_duration(max(options)))
    end
    
  end
end
