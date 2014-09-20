module Ricer
  class Locale < ActiveRecord::Base
    
    with_global_orm_mapping
    def should_cache?; true; end
    def cache_key; iso; end

    def self.valid?(iso)
      exists?(iso)
    end

    def self.exists?(iso)
      !!self.by_iso(iso)
    end
    
    def self.by_iso(iso)
      global_cache[iso] || find_by(:iso => iso)
    end
    
    def to_label
      I18n.t!("ricer.locale.#{self.iso}") rescue self.iso
    end

  end
end
