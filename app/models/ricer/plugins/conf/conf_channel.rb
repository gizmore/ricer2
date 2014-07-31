module Ricer::Plugins::Conf
  class ConfChannel < ConfBase
    
    trigger_is :confc
    scope_is :channel
    
    has_usage :set_var, '<plugin> <variable> <value>'
    has_usage :show_var, '<plugin> <variable>'
    has_usage :show_vars, '<plugin>'

    def config_scope; [:channel]; end

  end
end
