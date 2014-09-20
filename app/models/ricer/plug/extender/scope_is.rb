module Ricer::Plug::Extender::ScopeIs
  def scope_is(scope=:everywhere)
    class_eval do |klass|
      
      scope_object = Ricer::Irc::Scope.by_name(scope)
      throw Exception.new("#{klass.name} scope_is excepts a valid scope: #{scope}") if scope_object.nil?
      
      klass.register_class_variable('@scope')
      klass.register_instance_variable('@_scope')
      klass.instance_variable_set('@scope', scope_object)
      
      if scope != :everywhere
        klass.register_exec_function(:exec_scope!)
        def exec_scope!
          unless in_scope?(self.scope)
            raise Ricer::ExecutionException.new(I18n.t('ricer.plug.extender.scope_is.err_only_private')) if current_message.is_channel?
            raise Ricer::ExecutionException.new(I18n.t('ricer.plug.extender.scope_is.err_only_channel')) if current_message.is_query?
          end
        end
      end
      
      def scope
        @_scope ||= self.class.instance_variable_get('@scope')
      end

    end
  end
end
