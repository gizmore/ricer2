require 'uri'
class URI::Generic
  def domain
    self.class.domain(self.host)
  end
  def self.domain(hostname)
    self.domain!(hostname) rescue nil
  end
  def self.domain!(hostname)
    return ip6domain(hostname) if is_ip6?(hostname)
    return ip4domain(hostname) if is_ip4?(hostname)
    take = []
    quickparse(hostname).split('.').reverse.each do |part|
      take.unshift(part)
      # Stop if we have something longer than 3 letters and 2 parts are taken
      break if (part.length >= 3) && (take.count >= 2)
    end
    take.join('.')
  end
  
  def self.is_port?(s)
    return false unless s.is_a?(String) || s.is_a?(Integer)
    s.to_i.between?(1, 65535) rescue false
  end
  
  def self.is_ip?(hostname); is_ip4?(hostname) || is_ip6?(hostname); end
  def self.ip6domain(hostname); hostname; end
  def self.is_ip6?(hostname); !!/^[\da-f:]{3,36}$/i.match(hostname); end
  def self.ip4domain(hostname); hostname; end
  def self.is_ip4?(hostname); !!/^[\d.]{7,15}$/i.match(hostname); end
  
  def self.quickparse(hostname)
    if parsed = hostname.substr_from('://'); hostname = parsed; end
    hostname.substr_to(':') || hostname
  end

end
