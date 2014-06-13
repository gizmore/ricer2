module Ricer::Plugins::Gang
  class Gender

    def gender_name
      self.class.gender_name
    end
    
    def self.gender_name
      name.rsubstr_from('::').underscore.to_sym
    end
    
    def self.by_name(name)
      Game.gender.
      find_where({:name => arg})
    end
    
  end
end