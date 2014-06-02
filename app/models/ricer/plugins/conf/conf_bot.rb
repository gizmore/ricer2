module Ricer::Plugins::Conf
  class ConfBot < ConfBase
    
    trigger_is :confb

    has_usage :execute, '<plugin> [<variable>] [<value>]'

    def config_scope; [:bot]; end
    
  end
end
