module Ricer::Plug::Extender::TriggerIs
  def trigger_is(trigger, options={:announce=>false})

    Ricer::Plugin.register_class_variable('@default_trigger')

    class_eval do |klass|
      
      unless klass.instance_variable_defined?('@default_trigger')
        
        permission_is :public
        scope_is  :everywhere
        default_enabled  true
        flooding_protected true
        
        def_enabled = klass.instance_variable_get('@default_enabled')        
        has_setting name: :trigger_enabled,    type: :boolean,    scope: :channel, permission: :operator,  default: def_enabled
        has_setting name: :trigger_enabled,    type: :boolean,    scope: :server,  permission: :ircop,     default: def_enabled
#        has_setting name: :trigger_enabled,    type: :boolean,    scope: :bot,     permission: :owner,     default: def_enabled
        
#        has_setting name: :trigger_permission, type: :permission, scope: :user,    permission: :responsible, default: :public
#        has_setting name: :trigger_permission, type: :permission, scope: :channel, permission: :founder,     default: :public
        has_setting name: :trigger_permission, type: :permission, scope: :server,  permission: :responsible, default: :public
#        has_setting name: :trigger_permission, type: :permission, scope: :bot,     permission: :responsible, default: :public
        
        if options[:announce]
        end
        
      end
 
      def enabled?
        get_setting(:trigger_enabled)
      end
    
      klass.instance_variable_set('@default_trigger', trigger.to_s.downcase)
      def triggered_by?(argline)
        (argline + ' ').start_with?(trigger+' ')
      end
      
      def reply(text)
        connection.send_privmsg(@message.reply_clone, text)
      end
      def areply(text)
        connection.send_action(@message.reply_clone, text)
      end
      def nreply(text)
        connection.send_notice(@message.reply_clone, text)
      end
      
      def rply(key, *args); reply t(key, *args); end
      def rplyp(key, *args); reply tp(key, *args); end
      def rplyr(key, *args); reply tr(key, *args); end

      def arply(key, *args); areply t(key, *args); end
      def arplyp(key, *args); areply tp(key, *args); end
      def arplyr(key, *args); areply tr(key, *args); end

      def nrply(key, *args); nreply t(key, *args); end
      def nrplyp(key, *args); nreply tp(key, *args); end
      def nrplyr(key, *args); nreply tr(key, *args); end
      
      def reply_exception(e)
        return if e.is_a?(Ricer::SilentCancel)
        return reply e.to_s if e.is_a?(Ricer::ExecutionException) || e.is_a?(ActiveRecord::RecordInvalid)
        bot.log_exception(e)
        return reply e.to_s if e.is_a?(Ricer::TriggerException)
        return reply(exception_message(e))
      end
      
      protected

      def connection
        @message.server.connection
      end
      
      def reply_target
        return sender if @message.is_query?
        return receiver
      end
      
      private
      
      def exception_message(e)
        I18n.t('ricer.err_exception', :message => e.message, :location => reply_backtrace(e))
      end
      
      def reply_backtrace(e)
        e.backtrace.each do |line|
          return line unless line.index('/models/ricer/').nil?
        end
        e.backtrace[0]
      end
      
   end

  end
end
