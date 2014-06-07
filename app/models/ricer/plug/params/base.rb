module Ricer::Plug::Params
  class Base

    def self.type_label(type); I18n.t!("ricer.plug.param.#{type}.label") rescue type.to_s.camelize; end
    
    def initialize(value=nil)
      set(value) unless value.nil?
    end
    
    def display(options={}, message=nil)
      convert_out!(@value, options, message)
    end

    def set(value, options={}, message=nil)
      @input,@value = value,convert_in!(value, options, message) 
    end
    
    def short_class_name; self.class.name.rsubstr_from('::') rescue self.class.name; end
    def param_type; short_class_name.underscore[0..-7].to_sym; end
    def param_label; self.class.type_label(param_type); end

    #######################
    ### Errors and I18n ###
    #######################
    def _fail(text); raise Ricer::ExecutionException.new(text); end
    def t(key, *args); I18n.t("ricer.plug.param.#{param_type}.#{key}", *args); end
    def default_error_text; t(:error); end
    def fail_type; _fail(I18n.t('ricer.plug.param.err_type', input: @input, value: @value, type: param_label)); end
    def fail(key, *args); _fail(t(key, *args)); end
    def fail_default; _fail(default_error_text); end
    def failed_input; fail_default; end
    def failed_output; fail_default; end
    
    ## Failsafe calls
    def convert_in!(input, options, message); convert_in!(input, options, message) rescue nil; end
    def convert_out!(value, options, message); convert_out!(value, options, message) rescue nil; end
    def convert_hint(value, options, message); convert_hint!(value, options, message) rescue nil; end
   
    ################
    ### Abstract ###
    ################
    def convert_in!(input, options, message)
      _fail("Called convert_in on Params::Base class.")
    end

    def convert_out!(value, options, message)
      _fail("Called convert_out on Params::Base class.")
    end
    
    def convert_hint!(value, options, message)
      _fail("Called convert_hint on Params::Base class.")
    end
    
  end
end
