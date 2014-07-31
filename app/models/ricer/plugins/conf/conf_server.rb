module Ricer::Plugins::Conf
  class ConfServer < ConfBase
    
    trigger_is :confs

    has_usage :set_var, '<plugin> <variable> <value>'
    has_usage :show_var, '<plugin> <variable>'
    has_usage :show_vars, '<plugin>'

    def config_scope; [:server]; end
    
  end
end
