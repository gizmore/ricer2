module Ricer::Plug
  class Usage
    
#    attr_reader :function, :pattern, :options, :params
    attr_reader :function, :options, :params

    def scope; Ricer::Irc::Scope.by_name(@options[:scope]) unless options[:scope].nil?; end
    def permission; @options[:permission]; end
    def allows_trailing?; @options[:allow_trailing] == nil ? false : !!@options[:allow_trailing]; end
#   def allows_trailing?; @options[:allow_trailing] == nil ? @params.nil? : !!@options[:allow_trailing]; end
    def max_params; @params.length rescue 0; end
    def param(index); @params[index] rescue nil; end
    
    ###########################################
    ### Upon initialization                 ###
    ### Create appropriate Param structures ###
    ###########################################
    def initialize(function=:execute, pattern='', options={})
      @function = function
#      @pattern = pattern.trim
      @options = options
      @params = nil
      parse_pattern(pattern) unless pattern.empty?
    end
    
    def parse_pattern(pattern)
      @params = []
      pattern.split(/ +/).each do |paramstring|
        @params.push(UsageParam.new(paramstring))
      end
    end
    
    #######################
    ### Argument Parser ###
    #######################
    def parse_args(plugin, message, throw_errors)
      # empty params
      if @params.nil?
        if allows_trailing?
          # allow trailing is always ok
          return [] 
        else
          # else only ok on empty argv
          return plugin.argv.length == plugin.subcommand_depth ? [] : nil
        end
      end
      # non empty params
      parse_param_args(plugin, message, throw_errors)
    end

    def parse_param_args(plugin, message, throw_errors)
      
      back = []
      args = plugin.argv # Read from pre-splitted argv
      
      # argv starts after command, e.g. '!ping foo'..
      # ..would start at index 1, and should maybe worry if it has trailing.
      i = one = plugin.subcommand_depth

      @params.each do |param|
        if param.is_eater?
          # <..message..eater..>
          begin
            arg = plugin.line.split(/ +/, i+1)[-1]
            arg = nil if arg.trim.empty?
          rescue Exception => e
            arg = nil
          end
          return nil if arg.nil? && param.is_mandatory?
          back.push(arg); # return immediately
          return back     # return immediately
        else
          # Single arg
          begin
            arg = args[i] == nil ? nil : param.parse(args[i], @options, message)
            return nil if arg.nil? && param.is_mandatory?
            i += 1         # Add arg :)
            back.push(arg) # Add arg :)
          rescue Ricer::ExecutionException => e
            raise e if throw_errors
            return nil
          end
        end
      end
      
      unless allows_trailing?
        return nil if (@params.length != (i - one)) || (args[i] != nil)
      end
      
      back
      
    end
    
  end
end
