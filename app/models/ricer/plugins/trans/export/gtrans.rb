require "net/http"
require "uri"

class Ricer::GTrans
  
  AUTO = 'auto'
  ISOS = 
  [ 'af', 'ar', 'az', 'be', 'bg', 'bn', 'ca', 'cs', 'cy', 'da', 
    'de', 'el', 'en', 'es', 'et', 'eu', 'fa', 'fi', 'fr', 'ga',
    'gl', 'gu', 'hi', 'hr', 'ht', 'hu', 'hy', 'id', 'is', 'it',
    'iw', 'ja', 'ka', 'kn', 'ko', 'la', 'lt', 'lv', 'mk', 'ms',
    'mt', 'nl', 'no', 'pl', 'pt', 'ro', 'ru', 'sk', 'sl', 'sq',
    'sr', 'sv', 'sw', 'ta', 'te', 'th', 'tl', 'tr', 'uk', 'ur',
    'vi', 'yi'
  ]
    
  def useragent
    "Mozilla/5.0 (X11; Linux x86_64; rv:14.0) Gecko/20100101 Firefox/14.0.1"
  end
  
  def valid_iso?(iso, allow_auto=true)
    (allow_auto && iso == AUTO) ||
    ISOS.include?(iso)
  end
  
  def check_iso!(iso, allow_auto=true)
    throw "GTrans does not know ISO #{iso}." unless valid_iso?(iso)
    true
  end
  
  def initialize(text, iso=AUTO)
    @text = text
    @iso = iso if check_iso!(iso)
  end
  
  def source_locale=(locale)
    @source = locale
  end
  
  def detect_iso
    iso = to('en').source_iso
    @iso = iso if @iso == AUTO
  end
  
  def to(iso)
    @cache ||= {}
    return @cache[iso] if @cache[iso] && check_iso!(iso) 
    uri = URI.parse("https://translate.google.com/?sl=#{@iso}&tl=#{iso}&q=#{URI::encode(@text)}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri, {'User-Agent' => useragent})
    response = http.request(request)
    @cache[iso] = {
      text: fetch_translation(response.body),
      source_iso: fetch_iso(response.body),
      target_iso: iso
    }
 end
 
 private
 def fetch_iso(response)
   Regexp.new("<a id=gt-otf-switch href=.+?&sl=(.+?)&").match(response)[1]
 end
 
 def fetch_translation(response)
   Regexp.new("<span id=result_box[^>]*><span[^>]*>([^<]+)</span>").match(response)[1]
 end
  
end
