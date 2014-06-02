# Three public static variables
class NamedId

  @minlen = DEFAULT_MINLEN = 2
  @maxlen = DEFAULT_MAXLEN = 32
  
  @allowed = DEFAULT_ALLOWED = 'a-z_0-9.'
  
  def self.maxlen; @maxlen; end
  def self.minlen; @minlen; end
  def self.allowed; @allowed; end
  def self.maxlen=(max); @maxlen = max; end
  def self.minlen=(min); @minlen = min; end
  def self.allowed=(allow); @allowed = allow; end
  
end
