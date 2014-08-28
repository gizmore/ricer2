module Ricer::Plugins::Data
	class Google < Ricer::Plugin

		trigger_is :google

		has_usage :execute, '<...message...>'

		def execute(message)
			google_url = "https://www.google.com/search?q=#{URI::encode(message)}"
			reply google_url
		end
	end
end