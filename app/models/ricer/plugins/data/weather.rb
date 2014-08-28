require "nokogiri"
require "open-uri"

module Ricer::Plugins::Data
	class Weather < Ricer::Plugin

		trigger_is :weather

		has_usage :execute, '<...message...>'

		def execute(city)
			url = "http://api.openweathermap.org/data/2.5/forecast?q=#{city}&mode=xml"
			Ricer::Thread.execute do 
				doc = Nokogiri::XML(open(url), nil, "UTF-8")
				data = doc.xpath("//temperature").first
				temp = data.attr("value")
				city = city
				min = data.attr("min")
				max = data.attr("max")
				# set.each {|s| reply s.to_s}
				reply "The temperature is around #{temp} celsius in #{city} and the minimum temperature is #{min} while the maximum temperature is #{max}"
			end
		end
	end
end