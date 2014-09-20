module Ricer::Plug
  class Usage
    
    include Ricer::Base::Base
    include Ricer::Base::Permissions
    
    attr_reader :function, :pattern, :params, :options
    attr_reader :scope, :permission, :force_throwing, :allow_trailing

    def forces_throwing?; force_throwing; end
    def allows_trailing?; allow_trailing; end

    def param(index); @params[index] rescue nil; end
    def max_params; @params ? @params.length : 0; end
    
    ###########################################
    ### Upon initialization                 ###
    ### Create appropriate Param structures ###
    ###########################################
    def initialize(function=:execute, pattern, options)
      @function = function
      @pattern = pattern
      @options = options
      @scope = @options[:scope] ? Ricer::Irc::Scope.by_name!(@options[:scope]) : nil
      @permission = @options[:permission] ? Ricer::Irc::Permission.by_name!(@options[:permission]) : Ricer::Irc::Permission::PUBLIC
      @force_throwing = !!options[:force_throwing]
      @allow_trailing = !!options[:allow_trailing]
      @params = pattern.empty? ? nil : parse_pattern(pattern)
    end
    
    def parse_pattern(pattern)
      pattern.split(/ +/).collect{ |paramstring| UsageParam.new(paramstring) }
    end

    def matches_scope_and_permission?(message)
      return false unless @scope.nil? || in_scope?(@scope)
      return false unless @permission.nil? || has_permission?(@permission)
      true
    end
    
    #######################
    ### Argument Parser ###
    #######################
    def parse_args(plugin, message, throw_errors)
      # empty params
      if @params.nil?
        if allows_trailing?
          [] # allow trailing is always ok
        else
          # else only ok on empty argv
          plugin.argline.empty? ? [] : nil
        end
      else # non empty params
        parse_params(plugin, message, forces_throwing?||throw_errors)
      end
    end

    def parse_params(plugin, message, throw_errors)
      
      bot.log_debug("Usage#parse_param_args: #{message.args[1]}")
      
      back, argline = [], plugin.argline.trim(' ')
      
      @params.each{ |param|
        
        # Out of data!
        return nil if argline.empty?

        # <..message..eater..>
        if param.is_eater?
          bot.log_debug("Usage#parse_params with eater #{param.to_label}: #{argline}")
          back.push(param.parse(argline, message))
          return back # Return with rest
        end
        
        # Eat one arg
        token = argline.substr_to(' ')||argline
        argline = argline.substr_from(' ').ltrim(' ') rescue ''
        begin # Parse the single arg
          bot.log_debug("Usage#parse_params with #{param.to_label} (#{token})#{argline}")
          back.push(param.parse(token, message))
        rescue Ricer::ExecutionException => e
          raise e if throw_errors
          return nil
        end
      }
      
      # Tokens left but parsers empty
      return nil unless allows_trailing? || argline.empty?
      
      back 
    end

  end
end
