module Ricer::Plug::Extender::RequiresConfirmation
  OPTIONS = {
    always: true,
    random: false,
  }
  def requires_confirmation(options={})
    
    merge_options(options, OPTIONS)
    
    class_eval do |klass|
      
      klass.register_exec_function(:execute_confirmation) if !!options[:always]
      
      klass.class_variable_set(:@@REQUIRES_RANDOM_WORD, !!options[:random])
      
      def execute_confirmation
        unless @@CONFIRM[user].nil?
          waitingfor = @@CONFIRM[user] + " #{confirmationword}"
          if waitingfor == privmsg_line
            @message.args[1].substr_to!(" #{confirmationword}")
            @@CONFIRM.delete(user)
            return
          end
        end
        @@CONFIRM[user] = privmsg_line
        raise Ricer::ExecutionException.new(tt('ricer.plug.extender.requires_confirmation.msg_confirm', command: @@CONFIRM[user], word: confirmationword))
      end
      
      @@CONFIRM = {}

      def confirmationword
        word = self.class.class_variable_get(:@@REQUIRES_RANDOM_WORD) ?
          SecureRandom.base64(3) :
          I18n.t('ricer.plug.extender.requires_confirmation.word')
      end
      
    end
  end
end
