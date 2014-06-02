class String
  
  # I need these sometimes but no string lib got those
  def substr_to(to)
    i = self.index(to)
    self[0..i-1] if i
  end

  def rsubstr_to(to)
    i = self.rindex(to)
    self[0..i-1] if i
  end
  
  def substr_from(from)
    i = self.index(from)
    self[i+from.length..-1] if i
  end
  
  def rsubstr_from(from)
    i = self.rindex(from)
    self[i+from.length..-1] if i
  end

  # Trimming, lovely trimming
  def trim(chars="\r\n\t "); ltrim(chars).rtrim(chars); end
  def trim!(chars="\r\n\t "); replace(trim(chars)); end
  def ltrim!(chars="\r\n\t "); replace(ltrim(chars)); end
  def rtrim!(chars="\r\n\t "); replace(rtrim(chars)); end

  def ltrim(chars="\r\n\t ")
    i = 0
    while (i < self.length)
      break if chars.index(self[i]).nil?
      i += 1
    end
    self[i..-1]
  end
  
  def rtrim(chars="\r\n\t ")
    i = self.length - 1
    while (i >= 0)
      break if chars.index(self[i]).nil?
      i -= 1
    end
    self[0..i]
  end

end
