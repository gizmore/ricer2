module Ricer::Plugins::Conf
  class ConfBot < ConfBase
    
    trigger_is :confb
    always_enabled

    has_usage :set_var, '<plugin> <variable> <value>'
    has_usage :show_var, '<plugin> <variable>'
    has_usage :show_vars, '<plugin>'

    def config_scope; [:bot]; end
    def config_object; bot; end 
    
  end
end
