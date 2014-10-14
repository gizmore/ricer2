module Ricer
  class Event
    include Ricer::Base::Base
    include Ricer::Base::Events
    @@sl5_event_subscriptions = {}
  end
end
