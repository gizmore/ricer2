module Ricer::Plugins::Conf
  class ConfUser < ConfBase

    trigger_is :confu

    has_usage :set_var, '<plugin> <variable> <value>'
    has_usage :show_var, '<plugin> <variable>'
    has_usage :show_vars, '<plugin>'

    def config_scope; [:user]; end

  end
end
