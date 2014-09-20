module Ricer::Plugins::Server
  class Servers < Ricer::Plugin
    
    is_list_trigger :servers, :for => Ricer::Irc::Server, :per_page => 10
    
    def display_show_item(server, number)
      get_plugin('Server/Server').display_show_item(server, number)
    end

    def display_list_item(server, number)
      server.displayname
    end
    
    def search_relation(relation, search_term)
      relation.with_url_like(search_term)
    end
    
  end
end
