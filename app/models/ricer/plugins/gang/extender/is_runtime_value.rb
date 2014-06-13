module Ricer::Plugins::Gang
  module Extender::IsRuntimeValue
    def is_runtime_value(bool=true)
      class_eval do |klass|
        if bool
          def is_runtime_value?
            return true
          end
        else
          def is_runtime_value?
            return false
          end
        end
      end
    end
    # Assign false by default
    class_eval do |klass|
      klass.is_runtime_value false
    end
  end  

  Attribute.extend Extender::IsRuntimeValue
end
