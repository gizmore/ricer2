module Ricer
  class Event
    def initialize
    end
  end
  Event.extend Plug::Extender::KnowsEvents
end
