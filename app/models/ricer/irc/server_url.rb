# t.integer  "server_id",                   null: false
# t.string   "ip"
# t.string   "url",                         null: false
# t.boolean  "peer_verify", default: false, null: false
# t.datetime "created_at"
# t.datetime "updated_at"
module Ricer::Irc
  class ServerUrl < ActiveRecord::Base
    
    belongs_to :server
    
    validates :url, uri: { schemes: [:irc, :ircs, :http, :https] }
    
    def uri
      URI(url)
    end
    
    def ssl?
      uri.scheme.end_with?('s')
    end
    
    def hostname
      uri.hostname
    end
    
    def port
      uri.port
    end
    
    def domain
      uri.domain
    end
    
  end
end