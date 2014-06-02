module Ricer::Plug::Extender::HasUsage
  def has_usage(func=:execute, pattern='', options={})
    
    class_eval do |klass|
      
      Ricer::Plugin.register_class_variable('@usages')

      # Sanity      
      # mixed = {execute:mixed} if mixed.is_a?(String)
      # mixed = {mixed => ''} if mixed.is_a?(Symbol)
      # throw Exception.new("#{klass.name} has_usage expects a String, Symbol or Hash!") unless mixed.is_a?(Hash)
      
      # Current usages
      usages = klass.instance_variable_defined?('@usages') ? klass.instance_variable_get('@usages') : {}
      # Append
      options[:pattern] = pattern
      usages[func] = options
      # mixed.each do |method_name, parameter_pattern|
        # options[:pattern] = pattern
        # usages[method_name] = options
      # end
      klass.instance_variable_set('@usages', usages)
      
      # Register Exec Handler
      if true # usage_on_error
        klass.register_exec_function(:exec_show_usage)
      else
        klass.register_exec_function(:exec_usage)
      end
      
      def show_help
        show_usage
      end
      
      def show_usage
        reply I18n.t('ricer.plug.extender.has_usage.msg_usage',
          trigger: trigger, usage: get_usage_text, description: description,
          permission: scope_and_permission_text) 
      end

      #####################
      ### Exec Handlers ###
      #####################      
      def has_usage?
        true
      end
      
      protected

      def handlers
        self.class.instance_variable_get('@usages')
      end
      
      def exec_show_usage
        show_usage unless try_handlers
      end
      
      def exec_has_usage
        try_handlers
      end
      
      private
      
      def try_handlers
        handlers.each do |funcname, handler|
          if handler_matches_scope(handler)
            args = parse_handler_args(handler[:pattern])
            unless args.nil?
              @message.plugin_id = plugin_id
              process_event('ricer_on_trigger')
              send(funcname, *args)
              return true
            end
          end
        end
        return false
      end
      
      def handler_matches_scope(handler)
        in_scope?
        # return true if (handler[:scope].nil?) || (handler[:scope] == :everywhere)
        # return true if (handler[:scope] == :channel) && @message.is_channel?
        # return true if (handler[:scope] == :user) && @message.is_query?
        # return false
      end
      
      def parse_handler_args(handler)
        
        args = argv
        i = one = subcommand_depth
        
        #byebug
        
        return args[i].nil? ? [] : nil if handler.empty?

        back = []
                

        matches = handler.scan(/\[?<[^>]+>\]?/)
        
        matches.each do |match|
  #        byebug
          optional = is_optional(match)
          if match.index('..') != nil # Rest of line
            begin
              arg = argline.split(/ +/, i)[i-one]
              arg = nil if arg.trim.empty?
            rescue Exception => e
              arg = nil
            end
            return nil if (arg.nil?) && (!optional)
            back.push(arg)
            return back
          else
            if args[i].nil?
              arg = nil
            else
              arg = parse_handler_type_arg(match.trim('[<>]'), args[i], optional)
            end
            i += 1
          end
          
          return nil if (arg.nil?) && (!optional)
          
          back.push(arg)
          
        end
        
        return nil if (matches.length != (i - one)) || (args[i] != nil)
        
        back
        
      end
      def is_optional(match)
       return true if match[0] == '['
       return false
      end
      
      def parse_handler_type_arg(type, arg, optional)
        Ricer::Plug::Param::Base.parse(server, type, arg, handlers.length >= 2, @message)
      end


      def show_usage
        reply I18n.t('ricer.plug.extender.has_usage.msg_usage',
          trigger: trigger, usage: get_usage_text, description: description,
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
      
      def get_usage_text
        out = []
        handlers.each do |funcname, handler|
          matches = handler[:pattern].scan(/\[?<[^>]+>\]?/)
          i = -1;
          matches.each do |match|
            i += 1
            label = Ricer::Plug::Param::Base.type_label(match.trim('[<>]'))
            label = "..#{label}.." unless match.index('..').nil?
            out[i] ||= {
              total: 0,
              optional: 0,
              labels: {},
            }
            out[i][:total] += 1
            out[i][:optional] += 1 if match[0] == '['
            out[i][:labels][label] = match[0] == '['
          end
        end
        
        back = ''
        out.each do |slot|
          if slot[:total] == 1
            if slot[:optional] == 1
              back += " [<#{slot[:labels].keys[0]}>]"
            else
              back += " <#{slot[:labels].keys[0]}>"
            end
          elsif slot[:total] == slot[:optional]
            if slot[:optional] > 0
              back += " [<#{slot[:labels].keys.join('|')}>]"
            else
              back += " <#{slot[:labels].keys.join('|')}>"
            end
          else # slot[:total] != slot[:optional]
            if slot[:optional] > 0
              slot[:labels].each{ |key,str| slot[:labels][key] = slot[:labels][key] ? "[#{key}]" : key }
              back += " <#{slot[:labels].values.join('|')}>"
            else
              back += " <#{slot[:labels].keys.join('|')}>"
            end
          end
        end
        
        back.ltrim(' ')
      end
      
    end
  end
end
