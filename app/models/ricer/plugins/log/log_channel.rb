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
      case get_setting(:logtype)
      when :Binlog; Binlog.irc_message(current_message, input)
      when :Textlog; Textlog.irc_message(current_message, input)
      end
    end
    
    has_usage :execute_set, '<boolean>'
    def execute_set(boolean)
      exec "confc log enabled #{boolean}"
    end
    
    has_usage :execute_show
    def execute_show
      rply :msg_show, channel:channel.displayname, state:show_setting(:enabled, :channel)
    end
    
  end
end
