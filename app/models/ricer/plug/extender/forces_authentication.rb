module Ricer::Plug::Extender::ForcesAuthentication
  
  OPTIONS ||= {
    always: true
  }
  
  def forces_authentication(options={always:true})
    class_eval do |klass|

      merge_options(options, OPTIONS)
      
      klass.register_exec_function(:exec_auth_check!) if options[:always]
      
      def passes_auth_check?
        !failed_auth_check?
      end
      
      def failed_auth_check?
        (user.registered?) && (!user.authenticated?)
      end
      
      def auth_check_text
        I18n.t('ricer.plug.extender.forces_authentication.err_authenticate')
      end

      def exec_auth_check!
        if failed_auth_check?
          raise Ricer::ExecutionException.new(auth_check_text)
        end
      end

    end
  end
end
