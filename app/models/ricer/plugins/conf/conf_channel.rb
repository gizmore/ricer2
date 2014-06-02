module Ricer::Plugins::Conf
  class ConfChannel < ConfBase
    
    trigger_is :confc
    scope_is :channel
    
    has_usage :execute, '<plugin> [<variable>] [<value>]'

    def config_scope; [:channel]; end

  end
end
