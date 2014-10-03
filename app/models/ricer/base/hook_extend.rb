module Ricer::Base::HookExtend
  
  def all_hooks; @ricer_hooks rescue nil; end
  def all_hooks!; @ricer_hooks ||= {}; end
  def hooks(hook_name); if all = all_hooks; all[hook_name.to_sym]; end; end;
  def hooks!(hook_name); all_hooks![hook_name.to_sym] ||= []; end
  
  def add_hook(hook_name, hook_function=nil, &hook)
    hooks!(hook_name.to_sym).push(hook) if hook && (!hooks!(hook_name).include?(hook))
    hooks!(hook_name.to_sym).push(hook_function.to_sym) if hook_function && (!hooks!(hook_name).include?(hook_function))
    true
  end

  def remove_hook(hook_name, hook_function=nil, &hook)
    hooks(hook_name.to_sym).delete(hook_function.to_sym) if hook_function rescue nil
    hooks(hook_name.to_sym).delete(hook) if hook rescue nil
    true
  end

end
