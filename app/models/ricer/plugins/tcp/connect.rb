require 'socket'

require_relative 'disconnect'
require_relative 'submit'

module Ricer::Plugins::Tcp
  class Connect < Ricer::Plugin

    permission_is :voice

    trigger_is :connect

    has_usage :connect, '<host> <port>'

    def connect(host, port)
      tcp_connection = sender.instance_variable_get(:@ricer_tcp_plugin_connection)
      unless tcp_connection.nil?
        get_plugin('Tcp/Close').execute_close
        reply "Previous connection closed"
      end
      Ricer::Thread.execute do
        begin
          socket = TCPSocket.open(host, port)
          if socket
            reply "Connected"
          else
            reply "Couldn't connect"
          end


       # response = socket.read
       # reply response

        #user.instance_variable_set(:@ricer_tcp_plugin_connection, socket)
          sender.instance_variable_set(:@ricer_tcp_plugin_connection, socket)
          sender.instance_variable_set(:@ricer_tcp_plugin_host, host)
          sender.instance_variable_set(:@ricer_tcp_plugin_port, port)
        rescue => se
          byebug
        end
      end
    end
  end
end
