module Ricer::Plug::Extender::ScopeIs
  def scope_is(scope=:everywhere)
    class_eval do |klass|
      
      Ricer::Plugin.register_class_variable('@scope')

      scope_object = Ricer::Irc::Scope.by_name(scope)
      
      throw Exception.new("#{klass.name} scope_is excepts a valid scope: #{scope}") if scope_object.nil?
      
      klass.instance_variable_set('@scope', scope_object)
      
      if scope != :everywhere

        klass.register_exec_function(:exec_scope)

        def exec_scope
          unless in_scope?
            raise Ricer::ExecutionException.new(I18n.t('ricer.plug.extender.scope_is.err_only_private')) if @message.is_channel?
            raise Ricer::ExecutionException.new(I18n.t('ricer.plug.extender.scope_is.err_only_channel')) if @message.is_query?
          end
        end
      
      end
      
      def in_scope?
        scope.in_scope?(@message.scope)
      end
        
      def scope
        self.class.instance_variable_get('@scope')
      end

    end
  end
end
