module Ricer::Clamper
  def clamped(value, min, max)
    if value.is_a?(String)
      value = value.to_f if value.float?
      value = value.to_i if value.integer?
    end
    return min if (min != nil) && (value < min)
    return max if (max != nil) && (value > max)
    return value
  end 
end

module Ricer::Clamping
  def clamp(min=0, max=nil); self.class.clamped(self, min, max); end
  def clamp_min(min=0); clamp(self, min, nil); end
  def clamp_max(max=4123123123); clamp(self, nil, max); end
end

class Integer
  extend Ricer::Clamper
  include Ricer::Clamping
  def numeric?; true; end
  def float?; false; end
  def integer?; true; end
end
class Float
  extend Ricer::Clamper
  include Ricer::Clamping
  def numeric?; true; end
  def float?; true; end
  def integer?; false; end 
  def round_i; Math.round(self); end
end
class String
  extend Ricer::Clamper
  include Ricer::Clamping
  def numeric?; float?; end
  def float?; true if Float(self) rescue false; end
  def integer?; self.to_i.to_s == self; end
end
