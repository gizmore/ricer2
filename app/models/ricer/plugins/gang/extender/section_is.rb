module Ricer::Plugins::Gang
  module Extender::SectionIs
    def section_is(section)
      class_eval do |klass|
        klass.register_class_variable(:@gang_attr_section)
        klass.instance_variable_set(:@gang_attr_section, section)
        def self.section
          self.class.instance_variable_get(:@gang_attr_section)
        end
      end
    end
  end
  Attribute.extend Extender::SectionIs
end
