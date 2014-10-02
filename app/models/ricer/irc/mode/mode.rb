module Ricer::Irc::Mode
  class Mode < ModeData
    
    attr_reader :modestring
    
    def display
      "'#{@modestring}'"
    end
    
    def set_mode(modestring)
      modestring = replace_permission_symbols(modestring)
      @modestring ||= ''
      before = @modestring.clone
      modestring.each_char do |c|
        @modestring += c unless @modestring.index(c)
      end
      mode_changed if before != @modestring
      self
    end
    
    def remove_mode(modestring)
      modestring = replace_permission_symbols(modestring)
      @modestring ||= ''
      before = @modestring
      regexp = Regexp.new("[#{modestring}]")
      @modestring = @modestring.gsub(regexp, '')
      mode_changed if before != @modestring
      self
    end
    
    def mode_changed
      self
    end

    def permissions_from_mode
      permissions = 0;
      perm_config = ModeData.current.permissions
      @modestring.each_char{|symbol| permissions |= perm_config[symbol].bit if perm_config[symbol] }
      permissions
    end
    
    def replace_permission_symbols(modestring)
      self.class.current.permiss_map.each{|k,v|modestring.gsub!(k, v)}
      modestring
    end

  end
end
