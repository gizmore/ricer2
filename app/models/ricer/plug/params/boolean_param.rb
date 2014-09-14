module Ricer::Plug::Params
  class BooleanParam < Base
    
    def true_label; t(:true); end
    def false_label; t(:false); end
    
    def convert_in!(input, message)
      begin
        return true  if (input == '1') || (input.downcase == true_label.downcase)
        return false if (input == '0') || (input.downcase == false_label.downcase)
      rescue Exception => e
      end
      failed_input
    end

    def convert_out!(value, message)
      case value
      when true; true_label
      when false; false_label
      else; failed_input
      end
    end
    
  end
end
