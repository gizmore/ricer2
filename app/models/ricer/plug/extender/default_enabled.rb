module Ricer::Plug::Extender::DefaultEnabled
  def default_enabled(bool=true)
    class_eval do |klass|
      
      throw "#{klass.name} excepts extender default_enabled to pass a boolean." unless !!bool == bool
      
      klass.register_class_variable(:@default_enabled)
      if klass.instance_variable_defined?('@mem_settings')
        settings = klass.instance_variable_get('@mem_settings')
        settings.each do |setting|
          if setting[:name] == :trigger_enabled
            setting[:default] = bool
          end
        end
      end
      
      unless klass.instance_variable_defined?(:@default_enabled)
        klass.instance_variable_set(:@default_enabled, bool)
        klass.register_exec_function(:exec_enabled_check!)
        def exec_enabled_check!
          raise_disabled_exception unless get_setting(:trigger_enabled)
        end
        def raise_disabled_exception
          raise Ricer::ExecutionException.new(tr('plug.extender.default_enabled.err_disabled'))
        end
      end
      
    end
  end
end
