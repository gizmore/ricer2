module Ricer::Plug::Extender::RequiresRetype
  
  def requires_retype(options={always:true})
    
    class_eval do |klass|
      
      klass.register_exec_function(:execute_retype) if !!options[:always]

      def execute_retype
        waitingfor = @@RETYPE[user]
        @@RETYPE.delete(user)
        return if waitingfor == line
        @@RETYPE[user] = line
        raise Ricer::ExecutionException.new(tt('ricer.plug.extender.requires_retype.msg_retype'))
      end
      
      private

      @@RETYPE = {}

    end
      
  end

end