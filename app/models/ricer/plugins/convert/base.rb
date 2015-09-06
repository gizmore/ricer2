module Ricer::Plugins::Convert
  class Base < Ricer::Plugin

    trigger_is :base
    
    BASE64_CHARSET ||= '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-'
    
    has_setting name: :input_charset, permission: :public, scope: :user, type: :string, min: 64, max: 64, default: BASE64_CHARSET
    has_setting name: :output_charset, permission: :public, scope: :user, type: :string, min: 64, max: 64, default: BASE64_CHARSET
    
    def input_charset; get_user_setting(sender, :input_charset); end
    def output_charset; get_user_setting(sender, :output_charset); end
    
    has_usage '<integer[min=2,max=64]> <integer[min=2,max=64]> <..numbers..>'
    def execute(inbase, outbase, numbers)
      inchars = input_charset
      outchars = output_charset
      out = []
      numbers.split(/[^0-9a-z]+/i).each do |number|
        out.push(base_convert(number, inbase, outbase, inchars, outchars))
      end
      reply lib.join(out)
    end
    
    private
    
    def base_convert(number, inbase, outbase, inchars, outchars)
      as_ten = parse_to_base_10(number, inbase, inchars)
      number_to_base_n(as_ten, outbase, outchars)
    end
    
    def parse_to_base_10(number, inbase, inchars)
      result = 0
      number.each_char do |char|
        result *= inbase
        result += inchars.index(char)
      end
      result
    end
    
    def number_to_base_n(number, outbase, outchars)
      result = ''
      loop do
        number, mod = * number.divmod(outbase)
        result = outchars[mod] + result
        break if number == 0
      end
      result
    end

  end
end
