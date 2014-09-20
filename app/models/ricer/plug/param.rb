module Ricer::Plug
  class Param
    
    ###############
    ### Options ###
    ###############
    def self.merge_options(options, default_options, check_unknown=true)
      if check_unknown # Reverse merge only known options.
        options.keys.each do |k|
          unless default_options.key?(k)
            throw Exception.new("Unexpected option key: #{k}")
          end
        end
      end
      options.reverse_merge!(default_options)
    end
    
    #################
    ### Instances ###
    #################
    def self.parser_class(type)
      Object.const_get("Ricer::Plug::Params::#{type.camelize}Param")
    end

    def self.parser_class!(type)
      parser_class(type) or raise Ricer::RuntimeError.new("Param.parser_class! cannot find parser class: #{type}")
    end

    def self.parser(type, value=nil)
      self.parser!(type, value) rescue nil
    end

    def self.parser!(type, value=nil)
      options = parse_options!(type)
      parser_class(type).new(options, value)
    end

    def self.parse_options!(type)
      option_string = type.substr_from('[') or return nil
      type.substr_to!('[')
      _parse_options(option_string.rtrim!(']'))
    end

    def self._parse_options(string)
      options = nil
      string.split(/ *, */).each do |pair|
        pair = pair.split(/ *= */, 2)
        options ||= {}
        options[pair[0].to_sym] = pair[1]||pair[0].to_sym
      end
      options
    end

    #############
    ### Input ###
    #############
    def self.parse(type, input=nil, message=nil)
      parse!(type, input, message) rescue nil
    end

    def self.parse!(type, input, message=nil)
      parser!(type).convert_in!(input, message)
    end
    
    ##############
    ### Output ###
    ##############
    def self.display(type, value, message=nil)
      display!(type, input, message) rescue 'PARSE DISPLAY ERROR!!!'
    end

    def self.display!(type, value, message=nil)
      parser!(type).convert_out!(value, message)
    end
    
  end
end
