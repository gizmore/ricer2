module Ricer::Plugins::Server
  class JoinServer < Ricer::Plugin
    
    trigger_is :join_server
    permission_is :ircop
    
    has_setting name: :default_nick, type: :string, scope: :bot, permission: :responsible, default: Rails.configuration.ricer_nickname
    
    has_usage :execute_rejoin, '<server>'
    has_usage :execute_create, '<server_url>'
    
    def execute_rejoin(server)
      return rply :err_already_connected if server.connected?
      return rply :msg_rejoining, :server => server.displayname
    end
    
    def execute_create(server_url)
      nickname = get_setting(:default_nick)
      server = Ricer::Irc::Server.new({
        bot_id: bot.id,
        server_url: Ricer::Irc::ServerUrl.new({
          url: server_url,
        }),
        server_nicks: [
          Ricer::Irc::ServerNick.new({
            nickname: get_setting(:default_nick),
            hostname: Rails.configuration.ricer_hostname,
            realname: Rails.configuration.ricer_realname,
          }),
        ],
      })
      server.instance_variable_set('@just_added_by', sender)
      server.startup
    end
    
    def ricer_on_server_authenticated
      if server.instance_variable_defined?('@just_added_by')
        user = server.remove_instance_variable('@just_added_by')
        server.online = true
        server.save!
        server.global_cache_add
        user.localize!.send_privmsg(t('msg_connected',
          server: server.displayname,
          nickname: server.nickname.next_nickname,
          superword:generate_superword
        ))
      end
    end
    
    def ricer_on_connection_error
      server.try_more = false
    end
    
    def generate_superword
      password = SecureRandom.base64(6).gsub('/', 'a')
      super_plugin = get_plugin('Auth/Super')
      super_plugin.save_setting(:password, :server, password)
      password
    end
    
  end
end
