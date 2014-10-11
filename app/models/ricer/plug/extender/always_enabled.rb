###
### Removes enable/disable functionality
###
module Ricer::Plug::Extender::AlwaysEnabled
  def always_enabled(bool=true)
    class_eval do |klass|
      
      # Use default enabled
      klass.default_enabled true

      # Override the enable check
      def exec_enabled_check!
      end

      # Remove setting from the plugin to mimic it is not there
      if klass.instance_variable_defined?('@mem_settings')
        settings = klass.instance_variable_get('@mem_settings')
        settings.delete_if{|setting| setting[:name] == :trigger_enabled }
      end
      
    end
  end
end
