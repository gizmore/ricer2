module Ricer::Base::Hook
  
  def self.included(base); base.extend(Ricer::Base::HookExtend); end
  
  def hooks(hook_name); self.class.hooks(hook_name); end
  
  def add_hook(hook_name, hook_function=nil, &hook)
    self.class.add_hook(hook_name, hook_function=nil, &hook)
    self
  end

  def remove_hook(hook_name, hook_function=nil, &hook)
    self.class.remove_hook(hook_name, hook_function=nil, &hook)
    self
  end

  def call_hook(hook_name, *args)
    if hooks = self.hooks(hook_name)
      hooks.each{|hook| hook.is_a?(Symbol) ? send(hook, *args) : hook.call(*args) }
    end
    self
  end
  
end
