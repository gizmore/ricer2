module Ricer
  class Encoding < ActiveRecord::Base
    
    with_global_orm_mapping
    def should_cache?; true; end

    def self.valid?(iso)
      exists(iso)
    end

    def self.exists?(iso)
      where(:iso => iso).count > 0
    end
    
    def self.by_iso(iso)
      find_by(:iso => iso)
    end

    def to_label
      self.iso
    end
    
  end
end
