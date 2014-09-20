module Ricer::Plug
  class Setting < ActiveRecord::Base
    
    include Ricer::Base::Base
    include Ricer::Base::Translates
    
    attr_accessor :options

    SCOPES = [ :bot, :server, :channel, :user ]
    def self.scope_enum(scope); SCOPES.find_index(scope.to_sym); end

    belongs_to :plugin, :class_name => Ricer::Plugin.name, :dependent => :destroy
    belongs_to :entity, :polymorphic => true, :dependent => :destroy
    
    def self.validate_definition!(klass, options)
      throw Exception.new("#{klass.name} has_setting without [:name].") if options[:name].nil?
      setting_class = self.setting_class(options[:type])
      throw Exception.new("#{klass.name} has_setting with unknown [:type]: #{options[:type]}.") if setting_class.nil?
      setting_class.validate_definiton!(klass, options)
    end
    
    def setting_class
      self.class.setting_class(options[:type])
    end
    
    def self.setting_class(type)
      type = "#{type}_setting".classify
      Ricer::Plug::Settings.const_get(type);
#      Object.const_get("Ricer::Plug::Settings::#{type}")
    end

    def permission
      @_permission ||= Ricer::Irc::Permission.by_name(options[:permission])
    end

    def scope
      @_scope ||= Ricer::Irc::Scope.by_name(options[:scope])
    end
    
    def to_value
      setting_class.to_value(self.value)
    end
    
    def db_value
      setting_class.db_value(to_value)
    end
    
    def to_label
      setting_class.to_label(to_value)
    end
    
    def to_hint
      setting_class.to_hint(options)
    end
    
    def valid_value?(value)
      klass = setting_class
      klass.is_valid?(klass.to_value(value), options)
    end
    
    def equals_input?(input)
      self.to_value == setting_class.to_value(input)
    end

    def save_value(value)
      raise ExecutionExecption.new(tt('ricer.plug.setting.err_save', name: self.name, value: value, hint: to_hint)) unless valid_value?(value)
      klass = setting_class
      back = klass.to_value(value)
      self.value = klass.db_value(back)
      self.save!
      back
    end
    
  end
end
