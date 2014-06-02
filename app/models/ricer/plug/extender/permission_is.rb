module Ricer::Plug::Extender::PermissionIs
  def permission_is(permission=:public)
    class_eval do |klass|
      
      Ricer::Plugin.register_class_variable('@default_permission')
      
      permission = Ricer::Irc::Permission.by_name(permission)
      throw Exception.new("#{klass} permission_is invalid: #{permission}") if permission.nil?
      
      klass.instance_variable_set('@default_permission', permission.name)

      if permission.name != :public
        klass.register_exec_function(:exec_permission)
        if klass.instance_variable_defined?('@mem_settings')
          settings = klass.instance_variable_get('@mem_settings')
          settings.each do |setting|
            if setting[:name] == :trigger_permission
              setting[:default] = permission.name
            end
          end
        end

        def exec_permission
          unless has_permission?
            raise(Ricer::ExecutionException.new(I18n.t('ricer.plug.extender.permission_is.err_permission', permission: trigger_permission.to_label)))
          end
        end

      end
      
      def has_permission?(respect_auth=true)
        current_permission.has_permission?(trigger_permission, respect_permission)
      end

      def trigger_permission
        get_setting(:trigger_permission)
      end
      
      def respect_permission
        return Ricer::Irc::Permission::REGISTERED if @message.is_query?
        return sender.chanperm_for(channel).permission
      end
      
      def current_permission
        return sender.permission if @message.is_query?
        return sender.chanperm_for(channel).merged_permission
#        sender.permission.merge(sender.chanperm_for(channel).permission)
      end

    end
  end
end
