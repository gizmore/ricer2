module Ricer::Plugins::Conf
  class ConfServer < ConfBase
    
    trigger_is :confs

    has_usage :execute, '<plugin> [<variable>] [<value>]'

    def config_scope; [:server]; end
    
  end
end
