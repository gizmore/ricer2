module Ricer::Plug::Extender::HasDescription
  def has_description(langhash={en:'Oops'})
    
    Ricer::Plugin.register_class_variable('@default_description')

    class_eval do |klass|
      
      klass.instance_variable_set('@default_description', langhash)
      
    end
    
  end
end
