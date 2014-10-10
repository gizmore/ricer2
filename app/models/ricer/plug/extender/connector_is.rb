###
### Define for which connectors the plugin is designed.
###
### @example connector_is :irc
### @example connector_is [:irc, :icq]
###
module Ricer::Plug::Extender::ConnectorIs
  def connector_is(symbols=nil)

    # Basic sanity
    if symbols.nil?; symbols = []
    elsif symbols.is_a?(Array); # nothing todo
    elsif symbols.is_a?(Symbol); symbols = Array(symbols)
    else
      throw Exception.new("#{klass.name} 'has_connector' excepts a symbol or an array of symbols and not: #{symbols}")
    end
    symbols.each do |symbol|
      unless symbol.is_a?(Symbol)
        throw Exception.new("#{klass.name} 'has_connector' excepts a symbol or an array of symbols and not: #{symbols}")
      end
    end
    # End sanity

    # Add Connector checking behaviour
    class_eval do |klass|

      # Store the given connectors
      klass.register_class_variable(:@has_connectors)
      klass.instance_variable_set(:@has_connectors, symbols)

      # Retrieve them later
      def connector_symbols
        self.class.instance_variable_get(:@has_connectors)
      end

      # Register connector checker exec function
      klass.register_exec_function(:exec_connector_check)
      def exec_connector_check
        unless connector_supported?(current_message.server.connector_symbol)
          raise Ricer::ExecutionException.new(tt('ricer.plug.extender.connector_is.err_connector_unsupported'))
        end
      end

      # Checker helper
      def connector_supported?(connector_symbol)
        supported = connector_symbols
        supported.include?(connector_symbol.to_sym) || (supported.length == 0)
      end

    end
  end
end
