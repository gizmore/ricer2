module Ricer
  class Event
    include Ricer::Base::Base
    include Ricer::Plug::Extender::KnowsEvents
    def initialize
    end
  end
end
