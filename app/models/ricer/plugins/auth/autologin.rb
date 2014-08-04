module Ricer::Plugins::Auth
  class Autologin < Ricer::Plugin
    
    has_priority 25
    connector_is :irc
    
    def ricer_on_startup
      probe_server
    end
    
    def probe_server
      bot.log_debug "Probing #{server.displayname} on NickServ STATUS"
      server.connection.send_raw(@message, "PRIVMSG NickServ :STATUS #{server.nickname.name}")
    end

    def on_privmsg
      if @message.is_triggered?
        do_autologin if should_autologin
      end
    end
    
    # Probably response from Nickserv Status
    def on_notice
      if (sender.name.downcase == 'nickserv')
        matches = /^STATUS ([^ ]+) ([0-9])$/i.match(argline)
        return if matches.nil?
        username = matches[1]
        status = matches[2]
        if server.nickname.name.downcase == matches[1]
          server.instance_variable_set('@has_nickserv', true)
          server.instance_variable_set('@has_nickserv_status', true)
        else
          autologin(username)
        end
      end
    end
    
    # TODO: configure in ircd detection which statuscode really means autologin 
    def on_307; on_330; end
    def on_330; autologin(args[1]); end
    def autologin(username)
      user = Ricer::Irc::User.online.where(:nickname => username, server_id: server.id).first
      unless user.nil?
        user.login!
        user.localize!.send_message(I18n.t('ricer.plugins.auth.autologin.msg_logged_in'))
      end
    end
    
    def should_autologin
      return false unless user.registered?
      return false if user.authenticated?
      return false if tried_autologin_recently?
      return true
    end
    
    def tried_autologin_recently?
      if !user.instance_variable_defined?('@last_autologin')
        back = false
      else
        elapsed = Time.now.to_f - user.instance_variable_get('@last_autologin')
        back = elapsed < 15.minutes
      end
      user.instance_variable_set('@last_autologin', Time.now.to_f) unless back
      back
    end
    
    def do_autologin
      if server.instance_variable_defined?('@has_nickserv_status')
        server.connection.send_raw(@message, "PRIVMSG NickServ :STATUS #{user.name}")
      else
        server.connection.send_raw(@message, "WHOIS #{user.name}")
      end
    end
    
  end
end
