module Ricer::Plugins::Fun
	class Bed < Ricer::Plugin

		trigger_is :bed

		has_usage :execute

		def execute()
			user = sender.name
			case rand(0..1)
			when 0; rply :bed1, user:user
			when 1; rply :bed2, user:user
			end
		end
	end
end