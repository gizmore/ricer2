class Object
  def instance_variable_define(key, default_if_not_defined)
    instance_variable_defined?(key) ?
      instance_variable_get(key) :
      instance_variable_set(key, default_if_not_defined) 
  end
end
