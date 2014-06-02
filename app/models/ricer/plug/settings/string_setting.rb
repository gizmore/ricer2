module Ricer::Plug::Settings
  class StringSetting < Base
    
    def self.to_label(input)
     "\"#{input}\""
    end
    
    def self.min(options)
      options[:min] || 0
    end

    def self.max(options)
      options[:max] || 128
    end
    
    def self.to_hint(options={})
      I18n.t('ricer.plug.settings.hint.string', min: min(options), max: max(options))
    end
    
    def self.is_valid?(input, options)
      len = input.length
      return len >= min(options) && len <= max(options)
    end
    
  end
end
