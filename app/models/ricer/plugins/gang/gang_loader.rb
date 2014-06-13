module Ricer::Plugins::Gang
  class GangLoader

    def bot; Ricer::Bot.instance; end

    include Singleton
    
    attr_reader :npcs, :items, :spells, :cities, :locations, :races, :genders
    
    def gang_root; "#{Rails.root}/app/models/ricer/plugins/gang/"; end
    def gang_folder(dir); (gang_root + dir.trim('/')).rtrim('/') + '/'; end
    
    def class_qualifier(path)
      path.substr_from('/app/models/').camelize[0..-4]
    end
    
    def class_for_path(path)
      Object.const_get(class_qualifier(path)) rescue nil
    end
    
    def load(plugin)
      reload(plugin)
    end
    
    def reload(plugin)
      
      @npcs,@items,@spells,@cities,@locations,@races,@genders = {},{},{},{},{},{},{}
      
      Filewalker.traverse_files(gang_root, '*.rb') do |path|
        if klass = class_for_path(path)
          if klass < ActiveRecord::Base
            begin
              klass.upgrade_0
            rescue Exception => e
              bot.log_exception(e)
            end
          end
        end
      end

      Filewalker.traverse_files(gang_folder('lang'), '*.yml') do |path|
        I18n.load_path.push(path)
      end

      Filewalker.traverse_files(gang_folder('races'), '*.rb') do |path|
        if klass = class_for_path(path)
          load_race(plugin, klass)
        end
      end

      Filewalker.traverse_files(gang_folder('gender'), '*.rb') do |path|
        if klass = class_for_path(path)
          load_gender(plugin, klass)
        end
      end
           
      Filewalker.traverse_files(gang_folder('items'), '*.rb') do |path|
        if klass = class_for_path(path)
          load_item(plugin, klass)
        end
      end
      
      Filewalker.traverse_files(gang_folder('commands'), '*.rb') do |path|
        if klass = class_for_path(path)
          load_command(plugin, klass)
        end
      end
    
      Filewalker.traverse_files(gang_folder('spells'), '*.rb') do |path|
        if klass = class_for_path(path)
          load_spell(plugin, klass)
        end
      end
    
      Filewalker.traverse_files(gang_folder('world'), '*.rb') do |path|
        load_world_file(plugin, path)
      end
   
      Filewalker.traverse_files(gang_folder('locations'), '*.rb') do |path|
        load_world_file(plugin, path)
      end
   
      Filewalker.traverse_files(gang_folder('ai'), '*.rb') do |path|
        Player.extend(class_for_path(path))
      end
   
      # @cities.sort! do |a,b|
        # a.square_km - b.square_km
      # end

    end
    
    def load_world_file(plugin, path)
      if klass = class_for_path(path)
        load_npc(plugin, klass) if klass < Npc
        load_city(plugin, klass) if klass < City
        load_item(plugin, klass) if klass < Item
        load_spell(plugin, klass) if klass < Spell
        load_quest(plugin, klass) if klass < Spell
        load_command(plugin, klass) if klass < Command
        load_location(plugin, klass) if klass < Location
      end
    end
    
    def load_npc(plugin, klass)
      @npcs[klass.npc_class] = klass
    end
    def load_city(plugin, klass)
      @cities[klass.city_name] = klass
    end
    def load_item(plugin, klass)
      @items[klass.item_name] = klass
    end
    def load_spell(plugin, klass)
      @spells[klass.spell_name] = klass
    end
    def load_quest(plugin, klass)
      @quests[klass.quest_name] = klass
    end
    def load_command(plugin, klass)
#      plugin.add_subcommand(klass.name.demodulize.downcase)
    end
    def load_location(plugin, klass)
      @locations[klass.location_name] = klass
    end
    def load_race(plugin, klass)
      @races[klass.race_name] = klass
    end
    def load_gender(plugin, klass)
      @genders[klass.gender_name] = klass
    end

  end
end
