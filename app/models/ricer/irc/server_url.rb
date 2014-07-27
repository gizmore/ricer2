# t.integer  "server_id",                   null: false
# t.string   "ip"
# t.string   "url",                         null: false
# t.boolean  "peer_verify", default: false, null: false
# t.datetime "created_at"
# t.datetime "updated_at"
module Ricer::Irc
  class ServerUrl < ActiveRecord::Base
    
    belongs_to :server
    
    def uri
      URI(url)
    end
    
    def ssl?
      uri.scheme == 'ircs'
    end
    
    def hostname
      uri.hostname
    end
    
    def domain
      uri.domain
    end
    
  end
end