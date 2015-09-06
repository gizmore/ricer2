###
### Provides a hash of "cheat_prefix+hostname" => count
### Useful for functions a user may not do too often
###
module Ricer::Plug::Extender::HasCheatingDetection
  OPTIONS ||= {
    max_attempts: 1
  }
  def has_cheating_detection(options={})
    class_eval do |klass|
      
      # Options
      merge_options(options, OPTIONS)
    
      public
      
      # Sanity
      options[:max_attempts] = options[:max_attempts].to_i
      unless options[:max_attempts].between?(1, 10)
        throw "#{klass.name} has_cheating_detection max_attempts has to be between 1 and 10 but is: #{options[:max_attempts]}"
      end

      klass.instance_variable_set(:@max_cheat_attempts, options[:max_attempts])

      # Register klass variables for reload cleanup
      klass.register_class_variable(:@cheat_cache)
      klass.register_class_variable(:@max_cheat_attempts)
      klass.instance_variable_define(:@cheat_cache, {})
      
      # Call this for checking       
      def cheat_detection!(slot)
        raise Ricer::ExecutionException.new(cheat_detection_message) if cheat_detected?(slot)
      end
      
      def cheat_detected?(slot)
        cheat_attempts(slot) >= cheat_max_attempts
      end
      
      def cheat_detection_message
        I18n.t('ricer.plug.extender.has_cheating_detection.cheating_detected', :max_attempts => cheat_max_attempts)
      end
      
      def cheat_attempts(slot)
        cheat_cache[slot][cheat_key]||0 rescue 0
      end
      
      # Call this for inserting
      def cheat_attempt(slot)
        key = cheat_key
        cache = cheat_cache
        cache[slot] ||= {}
        cache[slot][key] ||= 0
        cache[slot][key] += 1
      end
      
      # Clearing
      def cheat_clear(slot)
        cheat_cache.delete(slot) rescue nil
      end

      # Purge
      def cheat_clear_all()
        self.class.instance_variable_set(:@cheat_cache, {})
      end
      
      private
      
      # Get the IP hostmask cloak part to detect renaming techniques
      def cheat_key
        current_message.prefix.substr_from('!').substr_from('@') rescue 'HAX0R'
      end
      
      def cheat_cache
        self.class.instance_variable_get(:@cheat_cache)
      end
      
      def cheat_max_attempts
        self.class.instance_variable_get(:@max_cheat_attempts)
      end
      
    end
  end
end
