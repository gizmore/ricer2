module Ricer::Plugins::Log
  class LogChannel < Ricer::Plugin
    
    trigger_is :log
    scope_is :channel
    permission_is :operator
    
    has_setting name: :enabled, type: :boolean, scope: :channel, permission: :operator, default: true
    has_setting name: :logtype, type: :enum,    scope: :channel, permission: :owner,    default: :Textlog, enums:[:Binlog, :Textlog]

    def ricer_on_receive
      log(true) if channel && setting(:enabled)
    end
    
    def ricer_on_reply
      log(false) if channel && setting(:enabled)
    end
    
    def log(input)
      #puts @irc_message.consolestring(input)
      case setting(:logtype)
      when :Binlog; Binlog.irc_message(@irc_message, input)
      when :Textlog; Textlog.irc_message(@irc_message, input)
      end
    end
    
    has_usage execute:'[<boolean>]'
    def execute(boolean)
      return show if boolean.nil?
      
      exec "confc log enabled #{argv[0]}"
    end
    
    def show
      rplyp :msg_show_channel, channel:channel.displayname, enabled:show_setting(:enabled, :channel)
    end
    
  end
end
