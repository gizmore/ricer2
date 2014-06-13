module Ricer::Plugins::Gang
  class Attributes::Carry < AttributeValue
    
    is_runtime_value
    section_is :stats
    
    def apply(player)
      player.set(:carry, data.player.carry_attributes.sum(:weight))
    end
    
    def overweight?
      player.get(:carry) > player.get(:max_carry)
    end
    
    def gang_before_movement
      raise Ricer::ExecutionException(t('err_overweight', :carry => player.get(:carry))) if overweight?
    end
    
  end
end
