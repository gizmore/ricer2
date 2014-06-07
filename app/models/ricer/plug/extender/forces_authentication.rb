module Ricer::Plug::Extender::ForcesAuthentication
  def forces_authentication(options={always:true})

    options[:always] = options.key? :always ? !!options[:always] : true

    # TODO: Implement a default option hash validation.
    # Error here if options has unexpected options
    # Sanitization of param types would be nice too
    # The lib kinda expects user input in code, so sanity checking extenders like "has_many" makes sense?

    class_eval do |klass|
      
      klass.register_exec_function(:exec_auth_check) if options[:always]

      def exec_auth_check
        if (user.registered?) && (!user.authenticated?)
          raise Ricer::ExecutionException.new I18n.t('ricer.plug.extender.forces_authentication.err_authenticate')
        end
      end
      
    end
    
  end
end
