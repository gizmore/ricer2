module Ricer::Plug::Extender::KnowsEvents
  
  def all_subscriptions
    Ricer::Event.class_variable_defined?(:@@sl5_event_subscriptions) ?
      Ricer::Event.class_variable_get(:@@sl5_event_subscriptions) :
      Ricer::Event.class_variable_set(:@@sl5_event_subscriptions, {})
  end

  def event_subscriptions(event)
    all_subscriptions[event] ||= []
  end

  def subscribe(event, &block)
    event_subscriptions(event).push(block)
  end

  def publish(event, *args)
    class_eval do |klass|
      event_subscriptions(event).each do |subscription|
        subscription.call(args)
      end
    end
  end

end
