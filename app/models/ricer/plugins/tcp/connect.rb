require 'socket'

require_relative 'disconnect'
require_relative 'submit'

module Ricer::Plugins::Tcp
  class Connect < Ricer::Plugin

    permission_is :voice
    
    trigger_is :connect

    has_usage :connect, '<host> <port>'

    def connect(host, port)
      tcp_connection = sender.instance_variable_get(:@ricer_tcp_plugin_connecti$
      get_plugin('Tcp/Close').execute_close unless tcp_connection.nil?
      begin
        Ricer::Thread.execute do
          socket = TCPSocket.open(host, port)
          if socket
            reply "Connected"
          else
            reply "Couldn't connect"
          end

        #user.instance_variable_set(:@ricer_tcp_plugin_connection, socket)
          sender.instance_variable_set(:@ricer_tcp_plugin_connection, socket)
          sender.instance_variable_set('@ricer_tcp_plugin_connection', socket)
          sender.instance_variable_get(:@ricer_tcp_plugin_host)
          sender.instance_variable_get(:@ricer_tcp_plugin_port, port)
        end
      rescue SocketError => se
        reply se
      end
    end
  end
end
