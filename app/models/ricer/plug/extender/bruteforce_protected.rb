module Ricer::Plug::Extender::BruteforceProtected
  def bruteforce_protected(options={})
    
    options[:always] ||= true
    options[:duration] ||= 7.seconds

    class_eval do |klass|

#      has_setting name: :bf_timeout, scope: :user,    permission: :ircop, type: :duration, default: options[:duration]
#      has_setting name: :bf_timeout, scope: :channel, permission: :admin, type: :duration, default: options[:duration]
      has_setting name: :bf_timeout, scope: :server, permission: :admin, type: :duration, default: options[:duration]
      has_setting name: :bf_timeout, scope: :bot, permission: :admin, type: :duration, default: options[:duration]

      Ricer::Plugin.register_exec_function(:not_bruteforcing?) if (!!options[:always])
      
      protected
      
      def timeout; get_setting(:bf_timeout); end
      
      def not_bruteforcing?
        !bruteforcing?
      end

      def bruteforcing?
        clear_tries
        if @@BF_TRIES[user].nil?
          register_attempt
          return false
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
        raise Exception.new(I18n.t('ricer.plug.extender.bruteforce_protected.err_bruteforce', timeout: display_timeout))
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
