class String
  
  # Substring until
  def substr_to(to)
    i = self.index(to)
    self[0..i-1] if i
  end
  def substr_to!(to); replace(substr_to(to)); end
  def rsubstr_to(to)
    i = self.rindex(to)
    self[0..i-1] if i
  end
  def rsubstr_to!(to); replace(rsubstr_to(to)); end
  
  # Substring from
  def substr_from(from)
    i = self.index(from)
    self[i+from.length..-1] if i
  end
  def substr_from!(from); replace(substr_from(from)); end
  def rsubstr_from(from)
    i = self.rindex(from)
    self[i+from.length..-1] if i
  end
  def rsubstr_from!(from); replace(rsubstr_from(from)); end
  
  # Trimming, lovely trimming
  TRIM = "\r\n\t "
  def trim(chars=TRIM); ltrim(chars).rtrim(chars); end
  def trim!(chars=TRIM); replace(trim(chars)); end
  def ltrim!(chars=TRIM); replace(ltrim(chars)); end
  def rtrim!(chars=TRIM); replace(rtrim(chars)); end

  def ltrim(chars=TRIM)
    i = 0
    while (i < self.length)
      break if chars.index(self[i]).nil?
      i += 1
    end
    self[i..-1]
  end
  
  def rtrim(chars=TRIM)
    i = self.length - 1
    while (i >= 0)
      break if chars.index(self[i]).nil?
      i -= 1
    end
    self[0..i]
  end

end
