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
        waitingfor = @@CONFIRM[user]
        @@CONFIRM.delete(user)
        return if waitingfor == line
        @@CONFIRM[user] = line + ' ' + confirmationword
        raise Ricer::ExecutionException.new(tt('ricer.plug.extender.requires_confirmation.msg_confirm', phrase:@@RETYPE[user]))
      end
      
      @@CONFIRM = {}

      def confirmationword
        word = self.class.class_variable_get(:@@REQUIRES_RANDOM_WORD) ?
          SecureRandom.base64(3) :
          I18n.t('ricer.plug.extender.confirm.word')
      end
      
    end
  end
end
