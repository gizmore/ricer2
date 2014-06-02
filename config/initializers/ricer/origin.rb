require 'uri'
class URI::Generic
  def domain(parts=2)
    self.class.domain(self.host, parts)
  end
  def self.domain(hostname, parts=2)
    self.domain!(hostname, parts) rescue nil
  end
  def self.domain!(hostname, parts=2)
    hostname.split('.').slice(-parts, parts).join('.')
  end
end
