module Ricer::Plugins::Convert
  class Maths < Ricer::Plugin

    trigger_is :math
    
    # Not too quick please
#    bruteforce_protected timeout: 1.5
    
    # Users can choose their own precision
    has_setting name: :precision, scope: :user, permission: :public, type: :integer, default: 4, min: 1, max: 12
    
    def description
      t(:description,
        constants: lib.join(MATH_CONSTANTS.keys.collect{|c|c.upcase}),
        functions: lib.join(MATH_FUNCTIONS),
      )
    end
    
    #################
    ### Variables ###
    #################
    def plugin_init; @@variables = {}; end
    def v; @@variables[sender] ||= []; end

    PHI = 0.61803398874989
    MATH_CONSTANTS = {
      'e' => Math::E,
      'pi' => Math::PI,
      'phis' => 1-PHI, # phi short
      'phil' => PHI,   # phi long
      'phia' => 2.40,  # Golden arc short
      'phib' => 3.88,  # Golden arc long
      'phi' => 1+PHI,  # Golden ratio
    } 
    
    MATH_FUNCTIONS = [
    # User variables
    'v',
    # math.rb from kernel mappings
    'acos', 'acosh',
    'asin', 'asinh',
    'atan', 'atan2', 'atanh',
#   'cbrt',
    'cos', 'cosh',
#   'erf', 'erfc',
    'exp',
#   'frexp',
#   'gamma',
#   'hypot',
#   'ldexp',
#   'lgamma',
    'log', 'log10', 'log2',
    'sin', 'sinh',
    'sqrt',
    'tan', 'tanh',
    # Other/Own helpers
    'round', 'floor', 'ceil',
    'deg', 'pow',
    ]
    
    MATH_SYMBOLS = '-+=*\\/%\\^&\\|\\.,;_0-9\\[\\]\\(\\)\\{\\} '

    REGEXP = Regexp.new("^(?:(?:[#{MATH_SYMBOLS}]+)|(?:[^.0-9a-z]?(?:#{MATH_FUNCTIONS.join('|')})[^.0-9a-z]?))+$")
    
    has_usage '<..term..>'
    def execute(term)
      # Beautify
      term = term.gsub(/\s+/, ' ').downcase
      # Replace math constants
      MATH_CONSTANTS.each{|k, v| term = term.gsub(k, v.to_s) }
      # Replace user variables
      term = term.gsub(/\$(\d{1,2})/) { v[$1.to_i] ||= 0; 'v['+$1+']' }
      # Hacker Checker after some letter replacement, some functions will slip through
      term_valid?(term) or return rply :err_forbidden
      # Exec!
      v[0] = BigDecimal.new(eval(term), get_setting(:precision)) # Probably an exception, but ricer will catch ;)
      # Reply the result :)
      reply v[0].to_s.rtrim('0').rtrim('.')
    end
    
    private
    
    def term_valid?(term)
      !!REGEXP.match(term)
    end

    #################
    ### Functions ###
    #################
    
    def acos(v); Math.acos(v); end
    def acosh(v); Math.acosh(v); end
    def asin(v); Math.asin(v); end
    def asinh(v); Math.asinh(v); end
    def atan(v); Math.atan(v); end
    def atan2(v); Math.atan2(v); end
    def atanh(v); Math.atanh(v); end
#   def cbrt(v); Math.cbrt(v); end
    def cos(v); Math.cos(v); end
    def cosh(v); Math.cosh(v); end
#   def erf(v); Math.erf(v); end
#   def erfc(v); Math.erfc(v); end
    def exp(v); Math.exp(v); end
#   def frexp(v); Math.frexp(v); end
#   def gamma(v); Math.gamma(v); end
#   def hypot(v); Math.hypot(v); end
#   def ldexp(v); Math.ldexp(v); end
#   def lgamma(v); Math.lgamma(v); end
    def log(v, base=nil); Math.log(v, base||Math::E); end
    def log10(v); Math.log10(v); end
    def log2(v); Math.log2(v); end
    def sin(v); Math.sin(v); end
    def sinh(v); Math.sinh(v); end
    def sqrt(v); Math.sqrt(v); end
    def tan(v); Math.tan(v); end
    def tanh(v); Math.tanh(v); end

    def pow(v, exp); v **= exp; end
    def root(v, root); v **= 1.0/root; end
    def ceil(v); v.ceil; end
    def floor(v); v.floor; end
    def round(v); v = v.round(get_setting(:precision)); end
    
    def deg(v); v.deg; end
    
  end
end
