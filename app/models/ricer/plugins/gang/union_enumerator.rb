module Ricer::Plugins::Gang
  class UnionEnumerator
    
    def self.each(*relations)
      relations.each do |relation|
        relation.each do |object|
          yield object
        end
      end
    end
    
  end
end
