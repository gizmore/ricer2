module Ricer::Plug::Extender::HasPriority
  def has_priority(priority=25)
    
    Ricer::Plugin.register_class_variable('@priority')
    
    class_eval do |klass|
      
      throw Exception.new("#{klass.name} has_priority with invalid priority: #{priority}") unless priority.between?(1, 100)
  
      klass.instance_variable_set('@priority', priority)
      
    end

  end
end
