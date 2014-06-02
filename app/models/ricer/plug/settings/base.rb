module Ricer::Plug::Settings
  class Base
    
    def self.bot; Ricer::Bot.instance; end
    def self.lib; Ricer::Irc::Lib.instance; end

    def bot; Ricer::Bot.instance; end
    def lib; Ricer::Irc::Lib.instance; end

    def self.validate_definiton!(klass, options)
      options[:default] ||= default_value(options)
      throw Exception.new "#{klass.name} setting is no hash: #{options.inspect}" unless options.is_a?(Hash)
      throw Exception.new "#{klass.name} setting #{options.inspect} has no name." if options[:name].nil?
#      throw Exception.new "#{klass.name} setting #{options[:name]} has no default value." if options[:default].nil?
      throw Exception.new "#{klass.name} has invalid default value: #{options[:default]}" unless default_valid?(options)
    end
    
    def self.default_value(options)
      options[:default]
    end
    
    def self.default_valid?(options)
      self.is_valid?(self.to_value(options[:default]), options)
    end
    
    def self.to_value(input)
      input.to_s rescue 'TO_VALUE_ERROR'
    end
    
    def self.db_value(input)
      input.to_s rescue 'DB_VALUE_ERROR'
    end
    
    def self.to_label(input)
      input.to_s rescue 'TO_LABEL_ERROR'
    end
    
    def self.to_hint(options)
      I18n.t("ricer.plug.settings.hint.#{options[:type]}")
    end
    
    def self.is_valid?(input, options)
      return input != nil
    end
    
  end
end
