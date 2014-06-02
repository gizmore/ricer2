module Ricer::Plugins::Conf
  class Conf < ConfBase
  
    trigger_is :conf

    has_usage :execute, '<plugin> [<variable>] [<value>]'

    def config_scope; Ricer::Plug::Setting::SCOPES; end

  end
end
