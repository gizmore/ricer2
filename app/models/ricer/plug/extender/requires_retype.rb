module Ricer::Plug::Extender::RequiresRetype
  def requires_retype(options={always:true})
    class_eval do |klass|
      
      # Add new exec handler to plugin exec chain
      klass.register_exec_function(:execute_retype!) if !!options[:always]
      
      def retyped?
        @@RETYPE.delete(user) == line
      end

      def execute_retype!(message="")
        return if retyped?
        @@RETYPE[user] = line
        message += " " unless message.nil? || message.empty?
        raise Ricer::ExecutionException.new(message+tt('ricer.plug.extender.requires_retype.msg_retype'))
      end
      
      private

      @@RETYPE = {}

    end
  end
end
