module Ricer::Irc
  class Lib
    
    include Singleton
    include ActionView::Helpers::NumberHelper
    include ActionView::Helpers::SanitizeHelper

    ACTION = "\x01"
    BOLD = "\x02"
    ITALIC = "\x03"
    
    
    def green(text)
      text
    end
        
    def nickname_valid?(nickname)
      /^[^\x00-\x1F\XFF!@%+]+$/i.match(nickname)
    end

    def channelname_valid?(channelname)
      /^[&#][^\x00-\x1F,\x7F]{1,199}$/iu.match(channelname)
     #/^[#&][-a-z0-9_]{1,199}$/.match(channelname) != nil
    end
    
    def bold(text)
      "\x02#{text}\x02"
    end
    
    def italic(text)
      "\x03#{text}\x03"
    end
    
    def action(text)
      "\x01#{text}\x01"
    end
    
    def obfuscate(string)
      [
        "A\xce\x91", "B\xce\x92", "C\xd0\xa1", "E\xce\x95", "F\xcf\x9c",
        "H\xce\x97", "I\xce\x99", "J\xd0\x88", "K\xce\x9a", "M\xce\x9c",
        "N\xce\x9d", "O\xce\x9f", "P\xce\xa1", "S\xd0\x85", "T\xce\xa4",
        "X\xce\xa7", "Y\xce\xa5", "Z\xce\x96",
        "a\xd0\xb0", "c\xd1\x81", "e\xd0\xb5", "i\xd1\x96", "j\xd1\x98",
        "o\xd0\xbe", "p\xd1\x80", "s\xd1\x95", "x\xd1\x85", "y\xd1\x83",
      ].each do |r|
        return string.sub(r[0], r[1..-1]) unless string.index(r[0]).nil?
      end
      return nil
    end
    
    def strip_html(html)
      strip_tags(html)
    end
    
    def softhype(string)
      min = string.length < 2 ? 0 : 1
      i = Ricer::Bot.instance.rand.rand(min...string.length);
      string[0..i] + "\xC2\xAD" + string[i..-1]
    end
    
    def no_highlight(string)
      obfuscate(string)||softhype(string)
    end

    def human_duration(seconds)
      return number_with_precision(seconds, precision:2)+'s' if seconds < 10
      seconds
    end

    def human_fraction(fraction, precision=1)
      number_with_precision(fraction, precision: precision)
    end
    
    def human_percent(fraction)
      human_fraction(fraction*100, 2)+'%'
    end
    
    def human_to_seconds(human)
      human
    end
    
  end
end
