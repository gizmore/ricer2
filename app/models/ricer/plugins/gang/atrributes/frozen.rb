module Ricer::Plugins::Gang
  class Attributes::Frozen < AttributeValue
    
    section_is :condition
    
    def gang_before_command
      if self.value > 0
        raise ExecutionException(t(:err_cannot_move))
      end
    end
    
  end
end
