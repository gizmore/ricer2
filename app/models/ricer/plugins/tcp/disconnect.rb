require 'socket'

require_relative 'connect'
require_relative 'submit'

module Ricer::Plugins::Tcp
  class Disconnect < Ricer::Plugin

    permission_is :voice

    trigger_is :disconnect

    has_usage :disconnect

    def disconnect
        tcp_connection = sender.instance_variable_get(:@ricer_tcp_plugin_connection)
        if tcp_connection.nil?
          reply "You are not connected to anything yet!"
        else
          sender.remove_instance_variable(:@ricer_tcp_plugin_connection)
          tcp_connection.close
          reply "Closed connection"
        end
    end
  end
end
