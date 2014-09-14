module Ricer::Plug::Params
  class Base

    def self.type_label(type); I18n.t!("ricer.plug.param.#{type}.label") rescue type.to_s.camelize; end
    
    attr_reader :input, :value, :options
    
    def initialize(options=nil, value=nil)
      @options = options
      @input = @value = nil
      set(value) unless value.nil?
    end
    
    ###############
    ### Options ###
    ###############
    def is_eater?; false; end # Override to force <..eater..mode..>
    DEFAULT_OPTIONS = {} # Guaranteed to reduce overhead?
    def options; @options || default_options; end
    def default_options; DEFAULT_OPTIONS; end
    def default_value; nil; end # DO NOT TOUCH!

    ###############
    ### Display ###
    ###############    
    def display(message=nil); convert_out!(@value, message); end
    def short_name; self.class.name.rsubstr_from('::') rescue self.class.name; end
    def param_type; short_name.underscore[0..-7].to_sym; end
    def param_label; self.class.type_label(param_type); end

    ############
    ### I18n ###
    ############
    def t(key, args={}); I18n.t!(tkey(key), args) rescue "#{key.to_s.rsubstr_from('.')||key}: #{args.inspect}"; end
    def tkey(key); key.is_a?(Symbol) ? "ricer.plug.params.#{param_type}.#{key}" : key; end 
    def default_error_text; t(:error); end
    
    ##############
    ### Errors ###
    ##############
    def fail(key, args={}); _fail(t(key, args)); end
    def _fail(text); raise Ricer::ExecutionException.new(text); end
    def fail_type; _fail(t('ricer.plug.params.err_type', input: @input, value: @value, type: param_label)); end
    def fail_default; _fail(default_error_text); end
    def failed_input; fail_default; end
    def failed_output; fail_default; end

    ######################    
    ### Failsafe calls ###
    ######################
    def set(value, message=nil); set(value, message) rescue false; end
    def set!(value, message=nil); @value = convert_in!(value, message) and @input = value and true; end
    def convert_in(input, message); convert_in!(input, message) rescue default_value; end
    def convert_out(value, message); convert_out!(value, message) rescue default_value; end
    def convert_hint(value, message); convert_hint!(value, message) rescue default_value; end

    ################
    ### Abstract ###
    ################
    def convert_in!(input, message); _fail("Called convert_in on Params::Base class."); end
    def convert_out!(value, message); _fail("Called convert_out on Params::Base class."); end
    def convert_hint!(value, message); _fail("Called convert_hint on Params::Base class."); end
    
  end
end

