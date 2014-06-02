module Ricer::Plug::Param
  class BooleanParam < Base
    
    def self.true_label; Ricer::Plug::Settings::BooleanSetting.true_label; end
    def self.false_label; Ricer::Plug::Settings::BooleanSetting.false_label; end

    def self.get_arg(server, arg, message)
      return true  if (arg == '1') || (arg.downcase == true_label.downcase)
      return false if (arg == '0') || (arg.downcase == false_label.downcase)
      nil
    end
    
  end
end
