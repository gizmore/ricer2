module Ricer::Plugins::Slapwarz
  class Model::Hit < ActiveRecord::Base
    
    self.table_name = :slap_hits
    
    def self.upgrade_1
      m = ActiveRecord::Migration
      m.create_table self.table_name do |t|
        t.integer   :user_id,      :null => false, :unsigned => true
        t.integer   :target_id,    :null => false, :unsigned => true
        t.integer   :damage,       :null => false, :unsigned => true
        t.integer   :adverb_id,    :null => false, :unsigned => true
        t.integer   :verb_id,      :null => false, :unsigned => true
        t.integer   :adjective_id, :null => false, :unsigned => true
        t.integer   :object_id,    :null => false, :unsigned => true
        t.datetime  :created_at,   :null => false
      end
    end
    
    def calculate_damage
      self.damage = ((100 * (object.damage-10) * (adverb.damage-10) * (verb.damage-10) * (adjective.damage-10)) / 1000).round 
    end
    
    def self.generate_slap(user, target)
      w = Model::Word
      adverb, verb, adjective, object = w.adverbs.random, w.verbs.random, w.adjectives.random, w.object.random
      slap = self.new(
        user_id: user.id,
        target_id: targetid,
        adverb_id: adverb.id,
        verb_id: verb.id,
        adjective_id: adjective.id,
        object_id: object.id,
      )
      slap.calculate_damage
    end
    
    def display_hit
      I18n.t("ricer.plugins.slapwarz.msg_hit",
        user: user.displayname,
        target: target.displayname,
        damage: damage,
        adverb: adverb.text,
        verb: verb.text,
        adjective: adjective.text,
        object: object.text,
      )
    end

    def display_item
      I18n.t("ricer.plugins.slapwarz.display_slap",
        id: self.id,
        user: user.displayname,
        target: target.displayname,
        damage: damage,
        adverb: adverb.text,
        verb: verb.text,
        adjective: adjective.text,
        object: object.text,
        ago: display_age,
      )
    end
    
  end
end
