module Ricer::Plugins::Purple
  class Yahoo < Violet
    
    def protocol
      'prpl-yahoo'
    end

    def after_connect
      @server.server_url.url = 'yahoo.com'
      @server.save!
    end

  end
end
