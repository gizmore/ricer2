    def apply(player)
      player.set_value(:carry, data.player.carry_attributes.sum(:weight))
    end
    
