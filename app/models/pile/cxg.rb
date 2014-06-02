module Pile
  class Cxg < Base
    
    require "uri"
    require "net/http"
    
    def do_upload(desc, pastetext, lang='text')
      
      byebug

      uri = URI.parse("http://cxg.de/index.html")
      
      http = Net::HTTP.new(uri.host, uri.port)

      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data({desc: desc, pastetext: pastetext, lang: lang})
      
      response = http.request(request)
      
      byebug
      puts "HI"
      
    end
    
  end
  
end
