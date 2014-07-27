module Ricer::Plug::Settings
  class EnumSetting < Base
    
    def self.validate_definiton!(klass, options)
      super(klass, options)
      throw Exception.new "#{klass.name} setting #{options[:name]} has no enums." if options[:enums].nil?
    end
    
    def self.to_value(input)
      input.to_sym
    end

    def self.to_label(input)
      input.to_sym
    end
    
    def self.to_hint(options)
      I18n.t('I18n.plug.settings.hint.enum', enums: options[:enums].join('|'))
    end
    
    def self.is_valid?(input, options)
      options[:enums].include?(input.to_sym)
    end
    
  end
end
