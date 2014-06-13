module Ricer::Plugins::Gang
  class Player < ActiveRecord::Base
    
    self.table_name = 'gang_players'
    def self.upgrade_0
      return if table_exists?
      m = ActiveRecord::Migration.new
      enum action: [:created, :loaded, :dead, :idle, :sleep, :inside, :outside, :move, :follow, :hunt, :fight, :travel]
      m.create_table table_name do |t|
        t.integer     :user_id,    :null => true
        t.float       :latitude,   :null => true
        t.float       :longitude,  :null => true
        t.integer     :action,     :null => false,  default: actions[:created]
        t.string      :target,     :null => true
        t.timestamp   :created_at, :null => false
      end
    end

    with_global_orm_mapping
    belongs_to :user, :class_name => 'Ricer::Irc::User'
    delegate :should_cache?, :server, :name, :displayname, :online, :to => :user
    
    def self.online; joins(:user).where("users.online = 1 OR user_id IS NULL"); end
    
    attr_reader :loaded, :base, :values

    scope :for_user, ->(user) { where({user: user}) }
    scope :doing, ->(action) { where({action: actions[action]}) }    
    scope :moving, -> { doing([:move, :following, :hunting, :fighting, :travel]) }
    scope :idleing, -> { doing([:inside, :outside, :idle, :created, :dead]) }
    
    def city; Game.city_for(self); end
    def location; Game.location_for(self); end
    def human?; !npc?; end
    def npc?; self.user_id.nil?; end

    def equipment_in(type)
      equipment.each do |item|
        return item if item.equipment_type == type
      end
      nil
    end
    
    def weapon
      equipment_in(:weapon)||fists
    end
    
    def fists
      Ricer::Plugins::Gang::Items::Weapons::Karate::Fists
    end

    has_many :items,  :class_name => 'Ricer::Plugins::Gang::Item', :through => :gang_player_items
    has_many :items_in, ->(slot) { items.where(:slot => PlayerItem.slots[slot]); }
    has_many :bank_items, ->(slot) { items_in(:bank) }
    has_many :mount_items, ->(slot) { items_in(:mount) }
    has_many :bazaar_items, ->(slot) { items_in(:bazaar) }
    has_many :inventory, ->(slot) { items_in(:inventory) }
    has_many :equipment, ->(slot) { items.where(:equipped => true) }

    has_many :item_values, :class_name => 'Ricer::Plugins::Gang::AttributeValue', :through => :gang_item_attributes
    has_many :item_values_in, ->(slot) { item_values.where(:slot => PlayerItem.slots[slot]) }
    has_many :bank_values, -> { item_values_in(:bank) }
    has_many :carry_values, -> { item_values_in([:inventory, :equipment]) }
    has_many :bazaar_values, -> { item_values_in(:bazaar) }
    has_many :inventory_values, -> { item_values_in(:inventory) }
    has_many :equipment_values, -> { item_values.where(:equipped => true) }
    
    has_many :item_attribs, :class_name => 'Ricer::Plugins::Gang::ItemAttribute'
    has_many :item_attribs_in, ->(slot) { item_attribs.where(:slot => PlayerItem.slots[slot]) }
    has_many :bank_attribs, -> { item_attribs_in(:bank) }
    has_many :carry_attribs, -> { item_attribs_in([:inventory, :equipment]) }
    has_many :bazaar_attribs, -> { item_attribs_in(:bazaar) }
    has_many :inventory_attribs, -> { item_attribs_in(:inventory) }
    has_many :equipment_attribs, -> { item_attribs.where(:equipped => true) }

    has_many :player_values, :class_name => 'Ricer::Plugins::Gang::AttributeValue', :through => :gang_player_attributes
    has_many :player_attribs, :class_name => 'Ricer::Plugins::Gang::PlayerAttribute'
    
    has_many :effect_values, :class_name => 'Ricer::Plugins::Gang::AttributeValue', :through => :gang_effect_attributes
    has_many :effect_attribs, :class_name => 'Ricer::Plugins::Gang::EffectAttribute'

    has_many :quests, :class_name => 'Ricer::Plugins::Gang::PlayerQuest', :through => :gang_player_quests
    has_many :quest_values, :class_name => 'Ricer::Plugins::Gang::AttributeValue', :through => :gang_quest_attributes
    has_many :quest_attribs, :class_name => 'Ricer::Plugins::Gang::QuestAttribute'
    
    has_many :spells, :class_name => 'Ricer::Plugins::Gang::Spell', :through => :gang_spell_attributes
    has_many :spell_values, :class_name => 'Ricer::Plugins::Gang::AttributeValue', :through => :gang_spell_attributes
    has_many :spell_attribs, :class_name => 'Ricer::Plugins::Gang::SpellAttribute'
    
    has_many :knowledge, :class_name => 'Ricer::Plugins::Gang::Knowledge'
    has_many :knowledge_for, ->(type) { knowledge.where(:type => Knowledge.types[type]) }
    has_many :known_knowledge, -> { knowledge_for(:knowledge) }
    has_many :known_places, -> { knowledge_for(:places) }
    has_many :known_word, -> { knowledge_for(:words) }
    
    def all_attribs
      UnionEnumerator.each(item_values, quest_values, player_values, spell_values, effect_values)
    end

    def effective_attribs
      UnionEnumerator.each(player_values, spell_values, equipment_values, effect_values)
    end
    
    def base_attribs
      UnionEnumerator.each(player_values, spell_values)      
    end
    
    ################
    ### Busytime ###
    ################
    def busytime; player.instance_variable_defined?(:@gang_busytime) ? player.instance_variable_get(:@gang_busytime) : 0.0; end
    def busyleft=(seconds=20.0); busytime = Time.now.to_f + seconds; end
    def busytime=(timestamp); player.instance_variable_set(:@gang_busytime, timestamp); end
    def busyleft; [busytime - Time.now.to_f, 0].max; end
    
    ##################
    ### Attributes ###
    ##################
    def increase_value(name, by=1)
      set_value(name, get_value(name) + by)
    end
    def set_value(name, value)
      @values[name.to_sym] = value
    end
    
    def get_value(name, default=-1)
      
    end
    
    def get_base(name, default=-1)
      player_attributes.where(:name => name).base
      Attribute.by_name(name)
    end
    
    def save_value(relation, name, base, bonus)
      relation.first_or_create({})
    end
    
    def set_base(attribute, value=nil)
      set_base(attribute.name, attribute.value) if attribute.is_a?(Ricer::Plugins::Gang::Attribute)
      @base[attribute.name.to_sym] = value
    end

    def set_value(value=nil)
      set_value(attribute.name, attribute.value) if attribute.is_a?(Ricer::Plugins::Gang::Attribute)
      @values[attribute.name.to_sym] = value 
    end
    
    def add_base(attribute, value=nil)
      add_base(attribute.name, attribute.value) if attribute.is_a?(Ricer::Plugins::Gang::Attribute)
      @base[attribute.name.to_sym] ||= (value.is_a?(String) ? '' : 0)
      @base[attribute.name.to_sym] += value
    end  

    def add_value(attribute, value=nil)
      add_value(attribute.name, attribute.value) if attribute.is_a?(Ricer::Plugins::Gang::Attribute)
      @values[attribute.name.to_sym] ||= (value.is_a?(String) ? '' : 0)
      @values[attribute.name.to_sym] += value
    end  

    ################
    ### Creation ###
    ################    
    after_create :after_create
    def after_create
      
      # Merge self, race, gender player variables
      this = self.class
      race = Race.by_name(options[:race])
      gender = Gender.by_name(options[:gender])
      base = merge_attributes(race.base_attributes, gender.base_attributes, this.base_attributes(player))
      bonus = merge_attributes(race.bonus_attributes, gender.bonus_attributes, this.bonus_attributes(player))
      bonus.each do |name,value|; base[name] ||= 0; end
      base.each do |name,value|; bonus[name] ||= 0; end
      bonus.keys.each do |name|
        player_values.create_attribute(name, base[name], bonus[name])
      end

      # Spell attributes
      base = merge_attributes(race.base_spell_attributes, gender.base_spell_attributes, this.base_spell_attributes(player))
      bonus = merge_attributes(race.bonus_spell_attributes, gender.bonus_spell_attributes, this.bonus_spell_attributes(player))
      bonus.each do |name,value|; base[name] ||= 0; end
      base.each do |name,value|; bonus[name] ||= 0; end
      bonus.keys.each do |name|
        spell_values.create_attribute(name, base[name], bonus[name])
      end
      
      Game.invoke(self, 'gang_on_create_player', self)

      Game.invoke(self, 'gang_on_rehash', self)
      
      Game.invoke(self, 'gang_on_created_player', self)
      
    end
    
    def gang_on_rehash
      
      @base = {}
      @values = {}
      
      effective_attribs.each do |attrib|

        name = attrib.name

        if attrib.has_base?
          if attrib.is_setting?
            @base[name] = @values[name] = attrib.setting
          elsif @base[name]
            @base[name] += attrib.base
            @values[name] += attrib.base
          else
            @base[name] = @values[name] = attrib.base
          end
        end

        if attrib.has_bonus?
          if attrib.is_setting?
            @values[name] = attrib.setting
          elsif @values[name]
            @values[name] += attrib.value
          else
            @values[name] = attrib.value
          end
        end
        
      end

      @loaded = true

    end
    
    def self.load(player)
      unless player.nil?
        Game.invoke(self, 'gang_on_rehash', player)
      end
      player
    end
    
    def self.current_user(user)
      self.player = by_user!(user)
    end

    def self.by_user(user)
      load(first({user:user}))
    end
    
    def self.by_user!(user)
      load(first_or_create({user:user}))
    end
    
    def self.by_id(id)
      load(find(id))
    end
    
    def self.by_arg(arg)
      load()
#      load_player(self.find(id))
    end
    
  end
end
