module Ricer::Plugins::Purple
  class Icq < Violet
    
    def protocol
      'prpl-icq'
    end

    def after_connect
      @server.server_url.url = 'icq.com'
      @server.save!
    end

  end
end
