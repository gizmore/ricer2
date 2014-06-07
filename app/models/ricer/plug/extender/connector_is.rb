module Ricer::Plug::Extender::ConnectorIs
  
#  def has_connectors(symbols=nil)
  def connector_is(symbols=nil)
    
    # Basic sanity
    if symbols.nil?; return
    elsif symbols.is_a?(Array); return if symbols.empty?
    elsif symbols.is_a?(Symbol); symbols = Array(symbols)
    else
      throw Exception.new("#{klass.name} 'has_connector' excepts a symbol or an array of them and not: #{symbols}")
    end
    
    # Add Connector checking behaviour
    class_eval do |klass|

      # # Check each symbol
      # symbols.each do |symbol|
        # unless bot.connector_symbols.include?(symbol)
          # throw Exception.new("#{klass.name} 'has_connector' has an unknown connector symbol: :#{symbol} in: #{symbols}")
        # end
      # end
    

      # Store the given connectors
      klass.register_class_variable('@has_connectors')
      klass.instance_variable_set('@has_connectors', symbols)
      
      # Retrieve them later
      def connector_symbols
        self.class.instance_variable_get('@has_connectors')
      end
      
      # Register connector checker exec function
      klass.register_exec_function(:exec_connector_check)
      def exec_connector_check
        unless connector_supported?(@message.server.connector_symbol)
          raise Ricer::ExecutionException.new I18n.t('ricer.plug.extender.connector_is.err_connector_unsupported')
        end 
      end
      
      # Checker helper
      def connector_supported?(connector_symbol)
        connector_symbols.include?(connector_symbol)
      end
      
    end
  end

  # # Singularized function name
  # def connector_is(symbols=nil); has_connectors(symbols); end
  # def has_connector(symbols=nil); has_connectors(symbols); end
  # def connectors_are(symbols=nil); has_connectors(symbols); end
  
end
