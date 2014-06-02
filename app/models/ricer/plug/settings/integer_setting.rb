module Ricer::Plug::Settings
  class IntegerSetting < Base
    
    def self.to_value(input)
      input.to_i rescue nil
    end
    
    def self.db_value(input)
      input.to_s
    end
    
    def self.to_label(input)
      input.to_s
    end
    
    def self.to_hint(options={})
      I18n.t('ricer.plug.settings.hint.integer', min: min(options), max: max(options))
    end
    
    def self.min(options)
      return options[:min] || 0
    end

    def self.max(options)
      return options[:max] || 4123123123
    end
    
    def self.is_valid?(input, options)
      return input != nil && input >= min(options) && input <= max(options)
    end
    
  end
end
