class UriValidator < ActiveModel::EachValidator
  
  def validate_each(record, attribute, value)
    
    begin
      @uri = URI(value)
      @record = record
      @attribute = attribute
      return unless valid_scheme?
      if ping?; return unless pings; end
      if exists?; return unless exists; end
      if connect?; return unless connects; end
    rescue => e
      record.errors[attribute] << message(:valid)
    end
    
  end

  private
  
  def ping?; options[:ping] || UriColumn.ping; end
  def exist?; options[:exist] || UriColumn.exist; end
  def connect?; options[:connect] || UriColumn.connect; end
  def trusted?; options[:ssl_trust] || true; end
  def scheme; @uri.scheme.to_sym; end
  def valid_scheme?
    unless schemes.include?(scheme)
      record.errors[attribute] << message(:scheme)
    end
  end
  def schemes; options[:schemes] || UriColumn.schemes; end
  
  
  
  def pings
    line = exec("ping -W 1.0 -c 1", @uri.host, "| grep '1 received'")
    puts line.inspect
  end
  def exists
    case scheme
    when [:http, :https]
    when [:irc]
    end
  end
  def connects
  end

  I18N = {
    ping: 'has an unreachable host',
    exist: 'cannot be found on the remote host',
    connect: 'refused the connection',
#    maxlen: 'is too long',
    scheme: 'uses a forbidden protocol',
    valid: 'is not a well formed uri',
    trust: 'points to a host with an invalid ssl cert'
  }

  def message(key)
    i18n_key = "active_record.validators.uri_validator.err_#{key}"
    I18n.exists?(i18n_key) ? I18n.t(i18n_key) : I18N[key]
  end  
  
end
