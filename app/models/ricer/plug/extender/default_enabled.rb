module Ricer::Plug::Extender::DefaultEnabled
  def default_enabled(bool=true)
    class_eval do |klass|
      
      throw Exception.new("#{klass.name} excepts extender default_enabled to pass a boolean.") unless bool == true || bool == false
      
      klass.register_class_variable('@default_enabled')
      if klass.instance_variable_defined?('@mem_settings')
        settings = klass.instance_variable_get('@mem_settings')
        settings.each do |setting|
          if setting[:name] == :trigger_enabled
            setting[:default] = bool
          end
        end
      end
      
      unless klass.instance_variable_defined?('@default_enabled')
        klass.register_exec_function(:exec_enabled_check)
        def exec_enabled_check
          unless get_setting(:trigger_enabled)
            raise Ricer::ExecutionException.new(I18n.t('ricer.plug.extender.default_enabled.err_disabled'))
          end
        end
      end

      klass.instance_variable_set('@default_enabled', bool)
      
    end
  end
end
