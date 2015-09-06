require "net/http"
require "uri"
require 'cgi'
#
# Code thankfully converted from "Nimda3" (noother´s highperformance PHP bot)
# @SEE https://github.com/noother/nimda3 
# Thanks my friend :)
#
class Ricer::GTrans
  
  AUTO ||= 'auto'
  ISOS ||= # translate.google.com supported
  [ 'af', 'ar', 'az', 'be', 'bg', 'bn', 'ca', 'cs', 'cy', 'da', 
    'de', 'el', 'en', 'es', 'et', 'eu', 'fa', 'fi', 'fr', 'ga',
    'gl', 'gu', 'hi', 'hr', 'ht', 'hu', 'hy', 'id', 'is', 'it',
    'iw', 'ja', 'ka', 'kn', 'ko', 'la', 'lt', 'lv', 'mk', 'ms',
    'mt', 'nl', 'no', 'pl', 'pt', 'ro', 'ru', 'sk', 'sl', 'sq',
    'sr', 'sv', 'sw', 'ta', 'te', 'th', 'tl', 'tr', 'uk', 'ur',
    'vi', 'yi'
  ]
  # Thx nufer ;)
  def useragent
    "Mozilla/5.0 (X11; Linux x86_64; rv:14.0) Gecko/20100101 Firefox/14.0.1"
  end

  
  def initialize(text="", iso=AUTO)
    check_iso!(iso)
    @text, @iso = text, iso
  end
  
  def valid_iso?(iso, allow_auto=true)
    (allow_auto && iso == AUTO) || ISOS.include?(iso.to_s)
  end
  
  def check_iso!(iso, allow_auto=true)
    valid_iso?(iso) or raise "The Google translator does not know this language iso2 code: #{iso}." 
  end
  
  def detect_iso
    iso = to('en')[:iso]
    @iso = iso if @iso == AUTO
  end
  
  def to(iso)
    check_iso!(iso)
    @cache ||= {}
    return @cache[iso] if @cache[iso]
    uri = URI.parse("https://translate.google.com/?sl=#{@iso}&tl=#{iso}&q=#{URI::encode(@text)}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri, {'User-Agent' => useragent})
    response = http.request(request)
    @cache[iso] = {
      text: fetch_translation(response.body),
      iso: fetch_iso(response.body),
      source_iso: @iso,
      target_iso: iso
    }
    store_detected_iso_as_cache
    @cache[iso]
  end
 
  private
 
  def store_detected_iso_as_cache
    @cache[@iso] = { text: @text, iso: @iso, source_iso: @iso, target_iso: @iso } unless @cache[@iso]
  end
 
  def fetch_iso(response)
    begin
      # THX NUFER!
      iso = Regexp.new("<a id=gt-otf-switch href=.+?&sl=(.+?)&").match(response)[1]
      @iso = iso if @iso == AUTO
    rescue StandardError => e
      nil
    end
  end
 
  # THX NUFER!
  def fetch_translation(response)
    CGI.unescapeHTML(Regexp.new("<span id=result_box[^>]*><span[^>]*>([^<]+)</span>").match(response)[1]) rescue nil
  end
  
end
