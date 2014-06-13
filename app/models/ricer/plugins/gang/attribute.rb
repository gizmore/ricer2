module Ricer::Plugins::Gang
  class Attribute < ActiveRecord::Base
    
    SECTIONS = [:attribute, :condition, :feeling, :hidden, :skill, :spell, :stat, :tuning, :crafting, :combat_skills, :unknown]
    def section; self.class.section; end
    def self.section; :unknown; end

    scope :in_section, ->(section) { attribute_class.section == section }
    
    self.table_name = :gang_attributes
    def self.upgrade_0
      unless table_exists?
        m = ActiveRecord::Migration.new
        m.create_table table_name do |t|
          t.string  :name
        end
      end
    end
    
    def self.by_name(name)
      first_or_create({name: name})
    end

    def attribute_class
      self.class.attribute_class
      #Object.const_get("Ricer::Plugins::Gang::Attributes::{self.name.classify}")
    end
    
    def self.attribute_class
      Object.const_get("Ricer::Plugins::Gang::Attributes::{self.short_name}")
    end
    
    def self.attribute_name
      short_name
    end
    
  end
end
