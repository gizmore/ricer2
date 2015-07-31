module Ricer::Plugins::Slapwarz
  class Model::Word < ActiveRecord::Base
    
    self.table_name = :slap_words
    
    ADVERB = 1
    VERB = 2
    ADJECTIVE = 3
    OBJECT = 4
    
    def self.upgrade_1
      m = ActiveRecord::Migration
      m.create_table self.table_name do |t|
        t.string    :name,       :null => false, :charset => :ascii
        t.integer   :slaptype,   :null => false, :length => 1,       :unsigned => true
        t.integer   :damage,     :null => false, :length => 4,       :unsigned => true
        t.timestamps
        t.datetime  :deleted_at, :null => true
      end
    end
    
    def self.adverbs; slapwords(ADVERB); end
    def self.verbs; slapwords(VERB).all; end
    def self.adjectives; slapwords(ADJECTIVE).all; end
    def self.objects; slapwords(OBJECT).all; end
    def self.slapwords(type); self.where(:slaptype => type); end
    
    def self.hit_column_for_type(type)
      case type
      when ADVERB; "adverb_id"
      when VERB; "verb_id"
      when ADJECTIVE; "adjective_id"
      when OBJECT; "object_id"
      end
    end
    
    def hit_column
      self.class.hit_column_for_type(self.slaptype)
    end
    
    def used
      Model::Hits.where("#{hit_column}=?", self.id).count
    end
    
  end
end
