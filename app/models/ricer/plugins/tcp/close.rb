require 'socket'

require_relative 'connect'

module Ricer::Plugins::Tcp
  class Close < Ricer::Plugin
    def execute_close
      tcp_connection = sender.instance_variable_get(:@ricer_tcp_plugin_connection)
      unless tcp_connection.nil?
        tcp_connection.close
        reply "Previous connection closed"
      end
    end
  end
end
