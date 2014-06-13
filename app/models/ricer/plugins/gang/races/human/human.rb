module Ricer::Plugins::Gang
  module Races
    class Human < Race
      
      def self.base_attributes(player)
        {
          :hp => 10, :max_hp => 10,
          :mp => 10, :max_hp => 10,

          # :max_skill => 100,
          # :max_attribute => 100,
          # :max_spell => 100,
          # :max_knowledge => 100,
#           
          :age => avg(18, 40),
          :bmi => avg(65..105),
          :height => avg(160..195),
           
          :body => 5,
          :magic => 5,
          :strength => 5,
          :intelligence => 5,
          :wisdom => 5,
          :quickness => 5,
          :charisma => 5,
          :luck => 5,
          :courage => 5,
          :reputation => 0,
          
          :casting => -1,
          :hp_recovery => -1,
          :mp_recovery => -1,

          :melee => -1,
          :swords => -1,
          :axes => -1,
          :blunt => 0,
          :thrust => 0,
          :knight => -1,
          :samurai => -1,
          :ninja => -1,
          :karate => -1,
          :firearms => -1,
          :bows => -1,
          :pistols => -1,
          :shotguns => -1,
          :smgs => -1,
          :hmgs => -1,
          :sharpshooter => -1,
          
          :searching => -1,

          :running => 0,
          :driving => -1,
          :swimming => 0,
          
          :trading => -1,
          :leadership => -1,

          :bioware => -1,
          :computers => -1,
          :hacking => -1,

          :lockpicking => -1,
          :stealing => -1,
          
          :alchemy => -1,
          :crafting => -1,
          :repairing => -1,
          :engineering => -1,
          :explosives => -1,
          
        }
      end
      
      def self.bonus_attributes(player)
        {
          :body => 5,
          :magic => 5,
          :strength => 5,
          :intelligence => 5,
          :wisdom => 5,
          :quickness => 5,
          :charisma => 5,
          :luck => 5,
          :courage => 5,
        }
      end
      
      def self.npc_names(npc)
        case npc.gender.name
        when :male
          ['Roderick', 'Jonas', 'Aaron']
        when :female
          ['Tiffany', 'Biancy', 'Joen']
        end
      end
      
    end
  end
end
