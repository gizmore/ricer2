require 'socket'

require_relative 'connect'
require_relative 'disconnect'

module Ricer::Plugins::Tcp
  class Submit < Ricer::Plugin
    permission_is :voice
    trigger_is :submit
    has_usage :submit, '<...message...>'

    def submit(message)
      Ricer::Thread.execute do
        tcp_connection = sender.instance_variable_get(:@ricer_tcp_plugin_connection)
        if tcp_connection.nil?
          reply "You aren't connected to anything yet!"
        else
          tcp_connection.send("#{message}")
          reply "Sending message..."
          if response = tcp_connection.recv(1000)
            reply response unless response.nil?
          else
            reply "Nothing was returned"
          end
        #byebug
        end
      end
    end
  end
end
