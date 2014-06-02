module Ricer::Plugins::Log
  class LogChannelShow < Ricer::Plugin
    
    trigger_is :log
    scope_is :channel

    has_usage
    def execute
      LogChannel.new(@irc_message).show
    end
    
  end
end
