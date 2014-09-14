module Ricer::Plug
  class Usage
    
    attr_reader :function, :params
    # attr_reader :function, :options, :params
    attr_accessor :force_throwing, :allow_trailing, :scope, :permission

    # def scope; @_scope||_scope; end
    # def _scope; @_scope ||= (@options[:scope] != nil ? Ricer::Irc::Scope.by_name(@options[:scope]) : nil); end
#    def permission; @options[:permission]; end
    def forces_throwing?; force_throwing; end
    def allows_trailing?; allow_trailing; end
    def max_params; @params == nil ? 0 : @params.length; end
    def param(index); @params[index] rescue nil; end
    
    ###########################################
    ### Upon initialization                 ###
    ### Create appropriate Param structures ###
    ###########################################
    def initialize(function=:execute, pattern, options)
      @function = function
#      @pattern = pattern
      @options = options
      self.scope = @options[:scope] ? Ricer::Irc::Scope.by_name!(@options[:scope]) : nil
      self.permission = @options[:permission] ? Ricer::Irc::Permission.by_name!(@options[:permission]) : Ricer::Irc::Permission::PUBLIC
      self.force_throwing = !!options[:force_throwing]
      self.allow_trailing = !!options[:allow_trailing]
      @params = pattern.empty? ? nil : parse_pattern(pattern)
    end
    
    def parse_pattern(pattern)
      pattern.split(/ +/).collect{ |paramstring| UsageParam.new(paramstring) }
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
        parse_param_args(plugin, message, forces_throwing?||throw_errors)
      end
    end

    def parse_param_args(plugin, message, throw_errors)
      
      back, argline = [], plugin.argline.trim(' ')
      
      @params.each{ |param|
        
        # Out of data!
        return nil if argline.empty?
        
        # <..message..eater..>
        if param.is_eater?
          back.push(param.parse(argline, message))
          return back # Return with rest
        end
        
        # Eat one arg
        token = argline.substr_to(' ')||argline
        argline.substr_from!(' ').ltrim!(' ') rescue argline = ''
        begin # Parse the single arg
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
