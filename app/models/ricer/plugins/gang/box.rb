module Ricer::Plugins::Gang
  class Box
    
    attr_reader :minlat, :maxlat, :minlon, :maxlon, :level
    
    RAD_ONE_METER = Geocoder::Calculations.distance_to_radians(0.001, :km)
    RAD_ONE_DECIM = Geocoder::Calculations.distance_to_radians(0.0001, :km)
    RAD_ONE_CENTI = Geocoder::Calculations.distance_to_radians(0.00001, :km)
    
    def initialize(minlat, maxlat, minlon=nil, maxlon=nil, level=0)
      @level = level
      if minlon.nil? && maxlon.nil?
        set_point(minlat, maxlat, RAD_ONE_DECIM)
      else
        set_box(minlat, maxlat, minlon, maxlon)
      end
    end
    
    def set_point(lat, lon, width=RAD_ONE_DECIM, height=nil)
      height ||= width
      width /= 2
      height /= 2
      @minlat, @maxlat = lat - width, minlat + width
      @minlon, @maxlon = lon - height, minlon + height
    end    
    def set_box(minlat, maxlat, minlon, maxlon)
      @minlat,@maxlat,@minlon,@maxlon = minlat,maxlat,minlon,maxlon
    end
    
    def matches?(box2)
      self.class.matches?(self, box2)
    end
    def self.matches?(box1, box2)
      box1.level == box2.level &&
      box1.minlat <= box2.maxlat && box1.maxlat >= box2.minlat &&
      box1.minlon <= box2.maxlon && box1.maxlon >= box2.minlon
    end

    def center; [(@minlat + @maxlat) / 2, (@minlon + @maxlon) / 2]; end
    def upper_left; [@minlat, @minlon]; end
    def upper_right; [@maxlat, @minlon]; end
    def lower_left; [@minlat, @maxlon]; end
    def lower_right; [@maxlat, @maxlon]; end
    def to_coordinates; center; end
    
    def square_km
      Geocoder::Calculations.distance_to(upper_left, lower_left, :km) *
      Geocoder::Calculations.distance_to(upper_left, upper_right, :km)
    end

  end
end
