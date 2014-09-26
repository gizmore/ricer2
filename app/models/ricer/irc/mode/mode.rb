module Ricer::Irc::Mode
  class Mode < ModeData
    
    attr_reader :modestring
    
    def set_mode(modestring)
      byebug
      @modestring ||= ''
      modestring.each_char do |c|
        byebug
        @modestring += c unless @modestring.index(c)
      end
    end
    
    def remove_mode(modestring)
      @modestring ||= ''
      regex = Regex.new("[#{modestring}]")
      @modestring.gsub!(regex)
    end
    
    def display
      "'#{@modestring}'"
    end
    
  end
end