###
### Protect a plugin against bruteforcing attempts, by using a timeout.
### All bruteforce protected plugins share the same timeout slot, so you cannot bruteforce all protected plugins each N seconds, only one of them.
### The timeout is configureable. the class method just sets a default.
###
### @example bruteforce_protected always: false, timeout: 10.seconds
###
### @option always  - indicates if the check shall be done automatically or you will need to call "#bruteforcing?" yourself.+
### @option timeout - the timeout which will unlock this plugin.
###
module Ricer::Plug::Extender::BruteforceProtected
  OPTIONS ||= {
    always: true,
    timeout: 7.seconds,
  }
  def bruteforce_protected(options={})
    
    merge_options(options, OPTIONS)

    class_eval do |klass|

      # Add timeout settings
      klass.has_setting name: :bf_timeout, scope: :server, permission: :ircop,       type: :duration, default: options[:timeout]
      klass.has_setting name: :bf_timeout, scope: :bot,    permission: :responsible, type: :duration, default: options[:timeout]

      # Register exec func when always
      klass.register_exec_function(:not_bruteforcing?) if options[:always]
      

      protected
      

      def timeout; get_setting(:bf_timeout); end
      def not_bruteforcing?; !bruteforcing?; end
      def bruteforcing?
        clear_tries
        if @@BF_TRIES[user].nil?
          register_attempt and return false
        else
          error_bruteforce
        end
      end
      

      private


      @@BF_TRIES = {}

      def display_timeout
        lib.human_duration(timeout_seconds)
      end
      
      def timeout_seconds
        @@BF_TRIES[user] - Time.now.to_f
      end
      
      def error_bruteforce
        raise Ricer::ExecutionException.new(
          tt('ricer.plug.extender.bruteforce_protected.err_bruteforce', time: display_timeout)
        )
      end
      
      def register_attempt
        @@BF_TRIES[user] = Time.now.to_f + timeout
      end
      
      def clear_tries
        @@BF_TRIES.each do |k,v|
          @@BF_TRIES.delete(k) if v < Time.now.to_f
        end
      end
      
    end
  end
end
