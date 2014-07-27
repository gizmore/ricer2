require 'uri'
class URI::Generic
  def domain
    self.class.domain(self.host)
  end
  def self.domain(hostname)
    self.domain!(hostname) rescue nil
  end
  def self.domain!(hostname)
    take = []
    hostname.split('.').reverse.each do |part|
      take.unshift(part)
      # Stop if we have something longer than 3 letters and 2 parts are taken
      break if (part.length >= 3) && (take.count >= 2) && (part.to_i.to_s != part)
    end
    take.join('.')
  end
end
