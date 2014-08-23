module Ricer::Plug::Extender::HasUsage
  
  DEFAULT_OPTIONS = {
    usage_on_error: true,
    allow_trailing: false,
    force_throwing: false,
  }
  
  # Extender has_usage
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
      unless klass.respond_to?(:on_privmsg)
        def on_privmsg; end
      end

      def trigger_visible?; true; end
      def trigger_possible?; true; end
      
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
        return unless trigger_possible?
        not_even_failed_one = true
        usages = usages_in_scope
        return if usages.empty?
        throw_error = usages.length
        usages.each do |pattern, usage|
          throw_error -= 1
          args = usage.parse_args(self, @message, (throw_error == 0))
          unless args.nil?
            @message.plugin_id = plugin_id
            process_event('ricer_on_trigger')
            before_execution
            begin
              send(usage.function, *args)
            rescue => e
              after_execution
              raise
            end
            after_execution
            return true
          end
          not_even_failed_one = false
        end
        not_even_failed_one
      end
      
      def usages_in_scope
        self.usages.usages_in_scope(@message)
      end
      
      ################
      ### Messages ###
      ################
      def show_usage
        reply get_usage
      end
      
      def get_usage
        I18n.t('ricer.plug.extender.has_usage.msg_usage',
          trigger: trigger, usage: display_usage_pattern, description: description,
          permission: scope_and_permission_text) 
      end
      
      def display_usage_pattern
        ' '+I18n.t!("#{i18n_key}.usage") rescue usages.combined_pattern_text(usages_in_scope)
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
      
      ####################
      ### Input Helper ###
      ####################
      def failed_input(key, *args)
        raise Ricer::ExecutionException.new(key.is_a?(Symbol) ? t(key,*args) : tt(key,*args))
      end
      
    end
  end
end
