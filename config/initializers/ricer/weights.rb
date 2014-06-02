class Integer
  def numeric?; true; end
  def float?; false; end
  def int?; true; end 
end
class Float
  def numeric?; true; end
  def float?; true; end
  def int?; false; end 
end
class String
  def numeric?; float?; end
  def integer?; self.to_i.to_s == self; end
  def float?; true if Float(self) rescue false; end
end
