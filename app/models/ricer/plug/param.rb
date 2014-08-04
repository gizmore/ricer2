module Ricer::Plug
  class Param
    
    ###############
    ### Options ###
    ###############
    def self.merge_options(options, default_options, check_unknown=true)
      options.reverse_merge!(default_options)
      if check_unknown
        options.keys.each do |k|
          unless default_options.key?(k)
            throw Exception.new("Unexpected option key: #{k}")
          end
        end
      end
      options
    end
    
    #################
    ### Instances ###
    #################
    def self.parser_class(type)
      Object.const_get("Ricer::Plug::Params::#{type.camelize}Param")
    end
    def self.parser(type, value=nil)
      self.parser!(type, value) rescue nil
    end
    def self.parser!(type, value=nil)
      parser_class(type).new(value)
    end

    #############
    ### Input ###
    #############
    def self.parse(type, input=nil, options={}, message=nil)
      parse!(type,input,options,message) rescue nil
    end

    def self.parse!(type, input, options={}, message=nil)
      parser!(type).convert_in!(input,options,message)
    end
    
    ##############
    ### Output ###
    ##############
    def self.display(type, value, options={}, message=nil)
      display!(type,input,options,message) rescue 'PARSE DISPLAY ERROR!!!'
    end

    def self.display!(type, value, options={}, message=nil)
      parser!(type).convert_out!(value,options,message)
    end
    
  end
end
