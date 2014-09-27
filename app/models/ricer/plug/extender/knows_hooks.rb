module Ricer::Plug::Extender::KnowsHooks

  def all_hooks
    @ricer_hooks ||= {}
  end
  
  def hooks(hook_name)
    all_hooks[hook_name] ||= []
  end
  
  def call_hook(hook_name, *args)
    hooks(hook_name).each do |hook|
      if hook.is_a?(Symbol)
        send(hook, *args)
      else
        hook.call(*args)
      end
    end
  end
  
  def add_hook(hook_name, hook_function=nil, &hook)
    if hook_function
      # hook_function = hook_function.to_sym
      hooks(hook_name).push(hook_function) unless hooks(hook_name).include?(hook_function)
    end
    if (hook)
     hooks(hook_name).push(hook) unless hooks(hook_name).include?(hook)
    end
    self
  end

  def remove_hook(hook_name, hook_function=nil, &hook)
    if hook_function
      hooks(hook_name).delete(hook_function.to_sym)
    end
    if (hook)
     hooks(hook_name).delete(hook)
    end
    self
  end

end
