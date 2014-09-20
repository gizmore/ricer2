module Ricer::Plugins::Purple
  class Msn < Violet
    
    def protocol
      'prpl-msn'
    end

    def after_connect
      @server.server_url.url = 'msn.com'
      @server.save!
    end
    
  end
end
