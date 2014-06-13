module Ricer::Plugins::Gang
  module Locations::IsSearchable

    def is_searchable(items={})
      class_eval do |klass|
        
      end
    end

  end
  Location.extend Locations::IsSearchable
end
