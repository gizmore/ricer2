module Ricer::Plug::Extender::HasUsage
  
  DEFAULT_OPTIONS = {
    usage_on_error: true,
    allow_trailing: false,
  }
  
  # Extender!
  def has_usage(function=:execute, pattern=nil, options={})
    class_eval do |klass|

      # Allow pattern as function and nil pattern      
      pattern, function = function, :execute if pattern.nil? && function.is_a?(String)
      pattern = '' if pattern.nil?
  
      # Options
      merge_options(options, DEFAULT_OPTIONS)
      usage_on_error = options.delete(:usage_on_error)
  
      # Sanity
      throw Exception.new("#{klass.name} has_usage expects function to be a Symbol, but it is: #{function}") unless function.is_a?(Symbol)
      throw Exception.new("#{klass.name} has_usage expects pattern to be a String, but it is: #{pattern}") unless pattern.is_a?(String)
      throw Exception.new("#{klass.name} has_usage expects options to be a Hash, but it is: #{options}") unless options.is_a?(Hash)
    
      # Append precompiled param handlers as usage
      Ricer::Plugin.register_class_variable('@usages')
      usages = klass.instance_variable_defined?('@usages') ? klass.instance_variable_get('@usages') : Ricer::Plug::Usages.new
      usages.add_pattern(function, pattern, options)
      klass.instance_variable_set('@usages', usages)
      
      # Register connector event handler by defining this here
      def on_privmsg; end
      
      # Register Exec Handler
      if usage_on_error
        klass.register_exec_function(:exec_has_usage!)
      else
        klass.register_exec_function(:exec_has_usage)
      end
      def exec_has_usage; try_handlers; end
      def exec_has_usage!; show_usage unless try_handlers; end

      # Usage
      def has_usage?; true; end
      def usages; self.class.instance_variable_get('@usages'); end
      def show_help; show_usage; end
      
      #####################
      ### Exec Handlers ###
      #####################      
      private
      def try_handlers
        not_even_failed_one = true
        usages.usages.each do |pattern, usage|
          if matches_scope_and_permission?(usage)
            args = usage.parse_args(self, @message)
            unless args.nil?
              @message.plugin_id = plugin_id
              process_event('ricer_on_trigger')
              send(usage.function, *args)
              return true
            end
            not_even_failed_one = false
          end
        end
        not_even_failed_one
      end
      
      def matches_scope_and_permission?(usage)
        return false unless usage.scope.nil? || @message.scope.in_scope?(usage.scope)
        return true
      end
      
      ################
      ### Messages ###
      ################
      def show_usage
        reply I18n.t('ricer.plug.extender.has_usage.msg_usage',
          trigger: trigger, usage: usages.combined_pattern_text(@message.scope), description: description,
          permission: scope_and_permission_text) 
      end
      
      def scope_and_permission_text
        if trigger_permission.bit == 0
          if scope.everywhere?
            ''
          else
            ' '+I18n.t('ricer.plug.extender.has_usage.scopeinfo_scope', scopelabel: scope.to_label)
          end
        else
          if scope.everywhere?
            ' '+I18n.t('ricer.plug.extender.has_usage.scopeinfo_perm', permission: trigger_permission.to_label)
          else
            ' '+I18n.t('ricer.plug.extender.has_usage.scopeinfo_both', scopelabel: scope.to_label, permission: trigger_permission.to_label)
          end
        end
      end
      
    end
  end
end
