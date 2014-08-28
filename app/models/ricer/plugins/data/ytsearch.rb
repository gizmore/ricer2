module Ricer::Plugins::Data
	class Ytsearch < Ricer::Plugin

		trigger_is :ytsearch

		has_usage :execute, '<...message...>'

		def execute(message)
			rply :link, message:message
		end
	end
end