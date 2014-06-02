module Ricer::Plug::Param
  class Base
    
    def self.lib; Ricer::Irc::Lib.instance; end

    def self.type_label(type)
      begin
        I18n.t!("ricer.plug.param.#{type}.label")
      rescue Exception => e
        type.to_s.camelize
      end
    end
    
    def self.validate_usage!(klass, funcname, usage)
      matches = /([?<[^>]+>]?)/.match(usage)
      unless matches.nil?
        matches.shift
        matches.each do |type|
          type = type.trim('[<>]')
          unless type[0] == '.'
            throw Exception.new("#{klass.name} has_usage #{funcname} has invalid usage type: #{type}") if get_parser(type).nil?
          end
        end
      end
    end
    
    def self.parse(server, type, arg, optional, message)
      param_value = get_parser(type).get_arg(server, arg, message)
      raise self.invalid_exception(type) if (param_value.nil?) && (!optional)
      param_value
    end
    
    def self.get_parser(type)
      Object.const_get("Ricer::Plug::Param::#{type.to_s.classify}Param")
    end
    
    def self.get_arg(server, arg, message)
      return arg
    end
    
    def self.invalid_exception(type)
      Ricer::ExecutionException.new(I18n.t("ricer.plug.param.#{type}.error"))
    end
    
  end
end
