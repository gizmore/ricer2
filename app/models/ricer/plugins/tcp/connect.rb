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
      get_plugin('Tcp/Close').execute_close unless tcp_connection.nil?
      begin
        Ricer::Thread.execute do
          socket = TCPSocket.open(host, port)
          if socket.nil?
            reply "Couldn't connect"
          else
            reply "Connected"
          end


          # response = socket.read
          # reply response
          sender.instance_variable_set(:@ricer_tcp_plugin_connection, socket)
          sender.instance_variable_set('@ricer_tcp_plugin_connection', socket)
          byebug
        end
      rescue SocketError => se
        reply se
      end
    end
  end
end
