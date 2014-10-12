module Ricer::Base::Hook
  
  def self.included(base); base.extend(Ricer::Base::HookExtend); end
  
  def all_hooks; @ricer_hooks rescue nil; end
  def all_hooks!; @ricer_hooks ||= {}; end
  def hooks(hook_name); if all = all_hooks; all[hook_name.to_sym]; end; end;
  def hooks!(hook_name); all_hooks![hook_name.to_sym] ||= []; end
  
  def add_hook(hook_name, hook_function=nil, &hook)
    hooks!(hook_name).push(hook) if hook && (!hooks!(hook_name).include?(hook))
    hooks!(hook_name).push(hook_function) if hook_function && (!hooks!(hook_name).include?(hook_function))
    self
  end

  def remove_hook(hook_name, hook_function=nil, &hook)
    hooks(hook_name.to_sym).delete(hook_function) if hook_function rescue self
    hooks(hook_name.to_sym).delete(hook) if hook rescue self
    self
  end

  def call_hook(hook_name, *args)
    call_hooks(hooks(hook_name), args)
    call_hooks(self.class.hooks(hook_name), args)
  end
  
  def call_hooks(hooks, args)
    hooks.each{|hook| hook.is_a?(Symbol) ? send(hook, *args) : hook.call(*args) } if hooks
    self
  end
  
end
