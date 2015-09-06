module Ricer::Plug::Extender::HasUsage
  
  DEFAULT_OPTIONS ||= {
    usage_on_error: true,
    allow_trailing: false,
    force_throwing: false,
    permission: :public,
    scope: nil,
  }
  
  # Extender has_usage
  def has_usage(function=:execute, pattern=nil, options=DEFAULT_OPTIONS)
    
    class_eval{|klass|

      # Allow pattern as function and nil pattern      
      pattern, function = function, :execute if pattern.nil? && function.is_a?(String)
      pattern = '' if pattern.nil?
      pattern = pattern.to_s
      pattern.trim!
  
      # Options
      merge_options(options, DEFAULT_OPTIONS)
      usage_on_error = options[:usage_on_error]
  
      # Sanity
      throw "#{klass.name} has_usage expects function to be a Symbol, but it is: #{function}" unless function.is_a?(Symbol)
      throw "#{klass.name} has_usage expects pattern to be a String, but it is: #{pattern}" unless pattern.is_a?(String)
      throw "#{klass.name} has_usage expects options to be a Hash, but it is: #{options}" unless options.is_a?(Hash)
    
      # Append precompiled param handlers as usage
      klass.register_class_variable('@usages')
      usages = klass.instance_variable_define('@usages', Ricer::Plug::Usages.new) 
      usages.add_pattern(function, pattern, options)
      
      # Register connector event handler by defining this here
      unless klass.respond_to?(:on_privmsg)
        def on_privmsg
        end
      end

      def trigger_visible?; true; end
      def trigger_possible?; true; end
      
      # Register Exec Handler
      if usage_on_error
        klass.register_exec_function(:exec_has_usage!)
      else
        klass.register_exec_function(:exec_has_usage)
      end
      def exec_has_usage!
        show_usage unless try_handlers
      end
      def exec_has_usage
        try_handlers
      end

      # Usage
      def has_usage?; true; end
      def usages; self.class.instance_variable_get('@usages'); end
      def show_help; reply get_help; end
      def get_help; get_usage; end
      
      # Hook here
      def before_execution; end
      def after_execution; end
      
      #####################
      ### Exec Handlers ###
      #####################      
      private
      def try_handlers
        usages = usages_in_scope
        if usages.length == 0
          raise Ricer::ExecutionException.new(tt('ricer.plug.extender.has_usage.err_no_usages_in_scope'))
        end
        throw_error = usages.length
        #bot.log_debug("HasUsage#try_handlers: #{self.plugin_name} with #{usages.count} usages in scope.")
        usages.each do |usage|
          #bot.log_debug("Trying #{self.plugin_name} with pattern #{usage.pattern} for #{usage.function}")
          throw_error -= 1
          execute_args = usage.parse_args(self, current_message, (throw_error == 0))
          unless execute_args.nil?
            #bot.log_debug("tried handler #{usage.pattern} successfully: #{execute_args.inspect}")
            current_message.plugin = self
            process_event('ricer_on_trigger') rescue nil
            begin
              # before_execution
              # process_event('ricer_before_execution') rescue nil
              send(usage.function, *execute_args)
            rescue StandardError => e
              bot.log_exception(e)
              raise e
            ensure
              # after_execution
              # process_event('ricer_after_execution') rescue nil
            end
            return true
          end
          # not_even_failed_one = false
        end
        false # not_even_failed_one
      end
      
      def usages_in_scope
        usages.in_scope(current_message)
      end
      
      ################
      ### Messages ###
      ################
      def show_usage
        reply get_usage
      end
      
      def get_usage
        tt('ricer.plug.extender.has_usage.msg_usage',
          trigger: trigger,
          description: description,
          usage: display_usage_pattern,
          permission: scope_and_permission_text,
        )
      end
      
      def display_usage_pattern
        ' '+I18n.t!("#{i18n_key}.usage") rescue usages.combined_pattern_text(usages_in_scope)
      end
      
      def scope_and_permission_text
        if trigger_permission.bit == 0
          if scope.everywhere?
            ''
          else
            ' '+tt('ricer.plug.extender.has_usage.scopeinfo_scope', scopelabel: scope.to_label)
          end
        else
          if scope.everywhere?
            ' '+tt('ricer.plug.extender.has_usage.scopeinfo_perm', permission: trigger_permission.to_label)
          else
            ' '+tt('ricer.plug.extender.has_usage.scopeinfo_both', scopelabel: scope.to_label, permission: trigger_permission.to_label)
          end
        end
      end
      
      ####################
      ### Input Helper ###
      ####################
      def failed_input(key, args={})
        raise Ricer::ExecutionException.new(t(key, args))
      end
      
    }
    true
  end
end
