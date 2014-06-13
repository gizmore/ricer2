module Ricer::Plugins::Gang
  class Commands::Start < Command
    
    trigger_is :start
    requires_player false
    
    has_usage '<race> <gender>'
    def execute(race, gender)

      byebug
      
      return rply :err_already_started unless player.nil?
      
      human = Player.create!({user:user})
      
      
      
      spawn :user_id => user.id
      
      race.attributes.each do |attribute, value|
        player.add_base(attribute, value)
#        player.add_value(attribute, value)
      end

      gender.attributes.each do |attribute, value|
        player.add_base(attribute, value)
#        player.set_value(attribute, value)
      end
      
    end
        
  end
end
