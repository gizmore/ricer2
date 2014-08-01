module Ricer::Plugins::Server
  class Nick < Ricer::Plugin
    
    trigger_is :nick
    scope_is :everywhere
    permission_is :ircop
    connector_is :irc

    has_usage :execute, '<nickname> <password>'
    
    has_usage :execute, '<nickname>'
    def execute(nickname, password=nil)
      return rply :err_nick_is_online if server.users.online.by_name(nickname).count > 1
      
      if nick != server.server_nicks.where(:name => nickname).first
        nick = Ricer::Irc::ServerNickname.new({
          server_id: server.id,
          nickname: nickname,
        })
        server.instance_variable_set('@new_nick', nick)
      end
      
      connection.send_nick()
    end
    
  end
end
