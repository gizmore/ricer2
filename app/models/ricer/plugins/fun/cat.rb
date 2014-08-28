module Ricer::Plugins::Fun
	class Cat < Ricer::Plugin

		trigger_is :cat

		has_usage :execute

		def execute()
			case rand(0..2)
			when 0; rply :cat1
			when 1; rply :cat2
			when 2; rply :cat3
			end
		end
	end
end