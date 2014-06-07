module Ricer::Plug::Extender::IsDescription
  def is_description(trigger)
    class_eval do |klass|
      
      has_usage :execute, '', :allow_trailing => true

      def execute
        reply description
      end
      
    end
  end
end
