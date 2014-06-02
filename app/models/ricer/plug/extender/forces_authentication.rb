module Ricer::Plug::Extender::ForcesAuthentication
  def forces_authentication(always=true)
    
    class_eval do |klass|
      
      klass.register_exec_function(:exec_auth_check) if always
      
      def exec_auth_check
        if (user.registered?) && (!user.authenticated?)
          throw Ricer::ExecutionException.new I18n.t('ricer.plug.extender.forces_authentication.err_authenticate')
        end
      end
      
    end
    
  end
end
