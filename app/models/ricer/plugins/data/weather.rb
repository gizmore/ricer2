#require "nokogiri"
#require "open-uri"
module Ricer::Plugins::Data
  class Weather < Ricer::Plugin

    trigger_is :weather

    has_usage :execute, '<..message..>'

    def execute(input)
      Ricer::Thread.execute do 
        url = "http://api.openweathermap.org/data/2.5/forecast?q=#{URI::encode(input)}&mode=xml"
        doc = Nokogiri::XML(open(url), nil, "UTF-8") rescue (raise t(:err_open_weather_connect))
        data = doc.xpath("//temperature").first or (return rply :err_open_weather_input)
        byebug
        rply :rpl_open_weather,
          city: 'CITY',
          temp_avg: data.attr("temp"),
          temp_min: data.attr("min"),
          temp_max: data.attr("max")
      end
    end
    
  end
end
