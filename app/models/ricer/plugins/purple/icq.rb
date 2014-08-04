module Ricer::Plugins::Purple
  class Icq < Purple
    
    def purple_protocol_symbol
      'ICQ'
    end
    
    def text_line(message)
      message[6..-8].trim!
    end

  end
end
