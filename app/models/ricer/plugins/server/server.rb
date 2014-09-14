module Ricer::Plugins::Server
  class Server < Ricer::Plugin
    
    is_show_trigger :server, :for => Ricer::Irc::Server
    
    def display_show_item(server, number)
      uri = URI(server.url)
      t(:show_server,
        url: "#{uri.host}:#{uri.port}",
        server: server.displayname,
        connector: server.connection.displayname,
        throttle: server.throttle,
        users_total: server.users.count,
        users_online: server.users.online.count,
        date_added: l(server.created_at, :long),
      )
    end
    
    def display_list_item(server, number)
      server.displayname
    end
    
    def search_relation(relation, search_term)
      relation.with_url_like(search_term)
    end
    
  end
end
