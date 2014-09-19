##
## trigger_is, :symbol
##
## Enriches plugins with some default settings and core extenders.
## [+] Reply functions and exception beautifier
##
module Ricer::Plug::Extender::TriggerIs
  def trigger_is(trigger)
    class_eval do |klass|

      trigger = trigger.to_sym
      
      klass.register_class_variable('@default_trigger')
      
      unless klass.instance_variable_defined?('@default_trigger')

        permission_is :public
        scope_is :everywhere
        default_enabled true
        flooding_protected true
        
        def_enabled = klass.instance_variable_get('@default_enabled')        
        has_setting name: :trigger_enabled,    type: :boolean,    scope: :channel, permission: :operator,    default: def_enabled
        has_setting name: :trigger_enabled,    type: :boolean,    scope: :server,  permission: :ircop,       default: def_enabled
        has_setting name: :trigger_enabled,    type: :boolean,    scope: :bot,     permission: :responsible, default: def_enabled
        
        has_setting name: :trigger_permission, type: :permission, scope: :channel, permission: :founder,     default: :public
        has_setting name: :trigger_permission, type: :permission, scope: :server,  permission: :responsible, default: :public
        
      end
 
      def enabled?
        get_setting(:trigger_enabled)
      end
    
      klass.instance_variable_set('@default_trigger', trigger.to_s.downcase)
      klass.instance_variable_set('@subcommand_depth', trigger.to_s.count(' ')+1)
      def triggered_by?(argline)
        (argline + ' ').start_with?(trigger+' ')
      end
      
      def ereply(text)
        current_message.errorneous = true
        connection.send_privmsg(current_message.reply_clone, text)
      end
      def reply(text)
        return if current_message.pipe!(text)
        connection.send_privmsg(current_message.reply_clone, text)
        current_message.chain!
      end
      def areply(text)
        return if current_message.pipe!(text)
        connection.send_action(current_message.reply_clone, text)
        current_message.chain!
      end
      def nreply(text)
        return if current_message.pipe!(text)
        connection.send_notice(current_message.reply_clone, text)
        current_message.chain!
      end
      
      def erply(key, args={}); ereply t(key, args); end
      def rply(key, args={})
        return ereply t(key, args) if key.to_s.start_with?('err_')
        return reply t(key, args)
      end
      def rplyp(key, args={}); reply tp(key, args); end
      def rplyr(key, args={}); reply tr(key, args); end

      def arply(key, args={}); areply t(key, args); end
      def arplyp(key, args={}); areply tp(key, args); end
      def arplyr(key, args={}); areply tr(key, args); end

      def nrply(key, args={}); nreply t(key, args); end
      def nrplyp(key, args={}); nreply tp(key, args); end
      def nrplyr(key, args={}); nreply tr(key, args); end
      
      def reply_exception(e)
        return if e.is_a?(Ricer::SilentCancel)
        if(e.is_a?(Ricer::ExecutionException) ||
           e.is_a?(ActiveRecord::RecordInvalid) || e.is_a?(ActiveRecord::RecordNotFound)
        )
          return ereply e.to_s
        end
        bot.log_exception(e)
        return ereply e.to_s if e.is_a?(Ricer::TriggerException)
        return ereply(exception_message(e))
      end
      
      protected

      def connection
        current_message.server.connection
      end

      # Send back to channel or query      
      def reply_target
        current_message.is_query? ? sender : receiver
      end
      
      private
      
      def exception_message(e)
        tt('ricer.err_exception', :message => e.message, :location => reply_backtrace(e))
      end
      
      def reply_backtrace(e)
        e.backtrace.each{|line| return line if line.index('/models/ricer/plugins') }
        e.backtrace.each{|line| return line if line.index('/models/ricer') }
        e.backtrace[0]
      end
      
    end
  end
end
