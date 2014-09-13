module Ricer::Plugins::Tcp
  class Tcp < Ricer::Plugin

    has_subcommand :connect
    has_subcommand :submit
    has_subcommand :disconnect
    has_subcommand :current

  end
end
