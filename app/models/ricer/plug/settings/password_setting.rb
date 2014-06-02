module Ricer::Plug::Settings
  class PasswordSetting < StringSetting
   
    def self.to_value(input)
      Ricer::Plug::Password.new(input)
    end
    
    def self.db_value(input)
      BCrypt::Password.create(input)
    end
   
    def self.to_label(input)
      I18n.t('ricer.plug.settings.blanked_password')
    end
    
    def self.to_hint(options={})
      I18n.t('ricer.plug.settings.hint.password', min: min(options))
    end
    
    def self.min(options)
      return options[:min] || 4
    end

    def self.is_valid?(input, options)
      return true if input.empty?
      len = input.length
      return len >= min(options) && len <= max(options)
    end

  end
end
