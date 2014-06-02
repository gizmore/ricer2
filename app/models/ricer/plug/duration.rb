module Ricer::Plug
  class Duration
    include ActionView::Helpers::NumberHelper
    
    def initialize(seconds)
      @seconds = seconds
    end
    
    def to_label; _to_label(@seconds); end
    def _to_label(seconds)
      return _to_ms(seconds) if @seconds < 10
      return seconds
    end
    
    def _to_ms(seconds)
      return seconds
    end
    
    
  end
end