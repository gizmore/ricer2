module Ricer::Plug::Extender::HasPriority
  def has_priority(priority=25)
    class_eval do |klass|
      
      unless priority.between?(1, 100)
        throw "#{klass.name} has_priority with invalid priority: #{priority}"
      end
  
      klass.register_class_variable('@priority')
      klass.instance_variable_set('@priority', priority)
      
    end
  end
end
