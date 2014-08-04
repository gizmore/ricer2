require 'nokogiri'
require 'open-uri'

module Ricer::Plugins::Fun
	class Wtf < Ricer::Plugin

		trigger_is :wtf
		
		has_usage :wtf, '<...message...>'
		
		def wtf(message)
			message.gsub!(/\s/, '+')
			ud = 'http://www.urbandictionary.com/define.php?term=' + message
			Ricer::Thread.execute do
				doc = Nokogiri::HTML(open(ud), nil, 'UTF-8')
				if doc.at_css('.meaning')
					meaning = doc.at_css('.meaning').content.strip
					example = doc.at_css('.example').content.strip
					rply meaning
					rply :example + example
			else
				rply :error_not_found
			end
		end
	end
end
