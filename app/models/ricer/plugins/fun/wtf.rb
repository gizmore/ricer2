require 'nokogiri'
require 'open-uri'

module Ricer::Plugins::Fun
  class Wtf < Ricer::Plugin

    trigger_is :wtf
    
    has_usage :execute_wtf, '<...message...>'
    
    def execute_wtf(message)
      Ricer::Thread.execute do
        urban_dictionary_url = "http://www.urbandictionary.com/define.php?term=#{URI::encode(message)}"
        doc = Nokogiri::HTML(open(urban_dictionary_url), nil, 'UTF-8')
        if doc.at_css('.meaning')
          reply doc.at_css('.meaning').content.strip
          example = doc.at_css('.example').content.strip rescue nil
          unless example.nil? || example.empty?
            rply :msg_example, example:example
          end 
        else
          rply :err_not_found
        end
      end
    end
    
  end
end
