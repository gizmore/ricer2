require 'socket'

require_relative 'disconnect'
require_relative 'submit'
require_relative 'connect'

module Ricer::Plugins::Tcp
  class Close < Ricer::Plugin
    def execute_close
      tcp_connection = sender.instance_variable_get(:@ricer_tcp_plugin_connection)
      tcp_connection.close
    end
  end
end
