module Ricer
  class Encoding < ActiveRecord::Base
    
    def self.valid?(iso)
      exists(iso)
    end

    def self.exists?(iso)
      where(:iso => iso).count > 0
    end
    
    def to_label
      self.iso
    end
    
  end
end
