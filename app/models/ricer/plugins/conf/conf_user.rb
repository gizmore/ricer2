module Ricer::Plugins::Conf
  class ConfUser < ConfBase

    trigger_is :confu

    def config_scope; [:user]; end

    has_usage :execute, '<plugin> [<variable>] [<value>]'

  end
end
