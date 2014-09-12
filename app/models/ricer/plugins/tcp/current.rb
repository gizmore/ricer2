module
require_relative 'connect'

permission_is :voice

trigger_is :current

has_usage :execute

def execute
	tcp_connection = sender.instance_variable_get(:@ricer_tcp_plugin_connection)
	if tcp_connection.nil?
		reply "You are not connected to anything yet!"
	else
		host = sender.instance_variable_get(:@ricer_tcp_plugin_host)
		port = sender.instance_variable_get(:@ricer_tcp_plugin_port)
		reply host unless host.nil?
		reply port unless port.nil?
	end

end
