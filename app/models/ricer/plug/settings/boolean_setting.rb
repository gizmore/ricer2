module Ricer::Plug::Settings
  class BooleanSetting < Base
    
    def self.to_value(input)
      return true  if (input == true)  || (input == '1') || (input == true_label)
      return false if (input == false) || (input == '0') || (input == false_label)
      nil
    end
    
    def self.db_value(input)
      return '1' if input == true
      return '0' if input == false
      nil
    end
    
    def self.to_label(input)
      return true_label if input == true
      return false_label if input == false
      raise RuntimeError.new "Somehow boolean is nil Oo"
    end
    
    def self.true_label
      I18n.t('ricer.plug.settings.boolean.bool_1')
    end
    
    def self.false_label
      I18n.t('ricer.plug.settings.boolean.bool_0')
    end
    
    def self.to_hint(options={})
      I18n.t('ricer.plug.settings.hint.boolean', on: true_label, off: false_label)
    end
    
  end
end
