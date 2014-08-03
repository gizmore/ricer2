require 'nokogiri'
require 'open-uri'

module Ricer::Plugins::Fun
	class Wtf < Ricer::Plugin

		trigger_is :wtf
		
		has_usage :wtf, '<...message...>'
		
		def wtf(message)
			message.gsub!(/\s/, '+')
			ud = 'http://www.urbandictionary.com/define.php?term=' + message
			doc = Nokogiri::HTML(open(ud), nil, 'UTF-8')
			meaning = doc.at_css('.meaning').content.strip
			example = doc.at_css('.example').content.strip
			reply meaning
			reply "Example: " + example
		end
	end
end