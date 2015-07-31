class Ricer::Text

  def to_s; return @text; end

  def initialize(text)
    @text = text
    @iso = nil
  end
  
end
