module Ricer::Plugins::Conf
  class Conf < ConfBase
  
    trigger_is :conf

    has_usage :set_var, '<plugin> <variable> <value>'
    has_usage :show_var, '<plugin> <variable>'
    has_usage :show_vars, '<plugin>'

    def config_scope; Ricer::Plug::Setting::SCOPES; end

  end
end
