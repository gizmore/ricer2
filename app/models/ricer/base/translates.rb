#
# Ricer translation helper
#
module Ricer::Base::Translates

  ############
  ### Time ###
  ############
  def l(date, format=:long); I18n.l(date, :format => format) rescue date.to_s; end

  ################
  ### I18n key ###
  ################
  def i18n_key; @_18nkey ||= self.class.name.gsub('::','.').underscore; end
  def i18n_pkey; @_18npkey ||= i18n_key.rsubstr_to('.'); end
  def tkey(key); key.is_a?(Symbol) ? "#{i18n_key}.#{key}" : key; end

  #################
  ### Translate ###
  #################  
  def t(key, args={}); tt tkey(key), args; end
  def tp(key, args={}); tt "#{i18n_pkey}.#{key}", args; end
  def tr(key, args={}); tt "ricer.#{key}", args; end
  #def tt(key, args={}); i18t(key, args); end
  def tt(key, args={}); rt i18t(key, args); end
  
  def i18t(key, args={}) # Own I18n.t that rescues into key: arg.inspect
    begin
      I18n.t!(key, args)
    rescue StandardError => e
      bot.log_exception(e)
      i18ti(key, args)
    end
  end

  def i18ti(key, args={}) # Inspector version
    vars = args.length == 0 ? "" : ":#{args.to_json}"
    "#{key.to_s.rsubstr_from('.')||key}#{vars}"
  end

  def rt(response) # Default replace
    begin
      response.to_s.
        gsub('$BOT$', server.nickname.name).
        gsub('$COMMAND$', (trigger.to_s rescue '')).
        gsub('$TRIGGER$', server.triggers[0]||'')
    rescue StandardError => e
      bot.log_exception(e)
      response
    end
  end
  
end
