class NamedIdValidator < ActiveModel::EachValidator

  I18N_ERR = 'active_record.validators.named_id_validator.err'; I18N_ERR_TXT = 'is an invalid NamedID'
  
  def validate_each(record, attribute, value)
    unless value =~ Regexp.new("^[a-z][#{NamedId.allowed}]{#{min-1},#{max-1}}$", true)
      record.errors[attribute] << message
    end
  end

  private
  
  def min
    options[:min] || NamedId.minlen
  end

  def max
    options[:max] || NamedId.maxlen
  end
  
  def message
    options[:message] || default_message
  end
  
  def default_message
    I18n.exists?(I18N_ERR) ? I18n.exists?(I18N_ERR) : I18N_ERR_TXT
  end
    
end
