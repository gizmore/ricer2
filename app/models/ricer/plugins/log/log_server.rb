module Ricer::Plugins::Log
  class LogServer < Ricer::Plugin
    
    def upgrade_1; Binlog.upgrade_1; end

    trigger_is :querylog
    permission_is :owner
    scope_is :user
    
    has_setting name: :enabled, type: :boolean, scope: :server, permission: :operator, default: true
    has_setting name: :logtype, type: :enum,    scope: :server, permission: :owner,    default: :Textlog, enums:[:Binlog, :Textlog]

    def ricer_on_receive
      log(true) if channel.nil? && setting(:enabled)
    end
    
    def ricer_on_reply
      log(false) if channel.nil? && setting(:enabled)
    end
    
    def log(input)
#      puts @irc_message.consolestring(input)
      case setting(:logtype)
      when :Binlog; Binlog.irc_message(@irc_message, input)
      when :Textlog; Textlog.irc_message(@irc_message, input)
      end
    end
    
    has_usage '[<boolean>]'
    def execute(boolean)
      return show if boolean.nil?
      
      exec "confs querylog enabled #{argv[0]}"
    end
    
    def show
      rplyp :msg_show_server, server:server.displayname, enabled:get_setting(:enabled, :server)
    end
    
  end
end
