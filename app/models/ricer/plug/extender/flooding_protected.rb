module Ricer::Plug::Extender::FloodingProtected
  def flooding_protected(boolean=true)
    class_eval do |klass|
      
      if boolean
      
        def flooding?
          last = user.instance_variable_defined?(:@last_msg_time) ? user.instance_variable_get(:@last_msg_time) : 0.0
          now = Time.now.to_f
          elapsed = now - last
          if elapsed <= server.cooldown
            bot.log_info "#{user.name} is FLOODING!"
            return true
          else
            user.instance_variable_set(:@last_msg_time, now)
            return false
          end
        end
      
      else
        
        def flooding?
          false
        end

      end
      
    end
  end
end
