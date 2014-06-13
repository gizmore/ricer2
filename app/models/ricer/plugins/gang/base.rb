module Ricer::Plugins::Gang
  module Base

    ##############
    ### Static ###
    ##############  
    def player; self.class.player; end;
    def self.player; Thread.current[:gang_player]; end
    def self.player=(player); Thread.current[:gang_player] = player; end

    def message; self.class.message; end;
    def self.message; Thread.current[:gang_message]; end
    def self.message=(message); Thread.current[:gang_message] = message; end
    
    def self.short_name; name.demodulize; end
    
    ###
    def merge_attributes(*attributes)
      back = {}
      attributes.each do |attribs|
        attribs.each do |name, value|
          if back[name]
            if value.is_a?(String)
              back[name] = value
            else
              back[name] += value
            end
          else
            back[name] = value
          end
        end
      end
      back
    end
    
    ##############
    ### Invoke ###
    ##############
    def invoke!(player, function, *args)
      UnionEnumerator.each(
        player.race,
        player.gender,
        player.effective_attributes,
        player.carry_items,
        player.quests,
        player.spells,
        player
      ) do |object|
        object.invoke(function, *args)
      end
    end
    
    def invoke(function, *args)
      send(function, *args) if self.class.respond_to?(function)
    end
    
    #############
    ### Spawn ###
    #############
    def spawn_mob(options={}, &proc)
      spawn(options.merge!({respawn:1}), proc)
    end
  
    def spawn_fight(options={}, &proc)
      spawn(options.merge!({respawn:0}), proc)
    end
  
    def spawn_stationary(options={}, proc)
      spawn(options.merge!({respawn:1, stationairy:1, fightable:1}), proc)
    end
    
    def spawn(options={}, &proc)
      options.reverse_merge!({respawn:0, stationary:0, fightable:1})
      npc = Npc.npc_class(options[:npc_class]).new
      npc.base_attributes(player).each do |name, value|
        npc.set_base(name, value)
      end
    end
    
  end

  # Extend all  
  [City, Location, Item, Player, Race, Gender, Spell, Command].each do |klass|
    klass.extend Base
  end
end
