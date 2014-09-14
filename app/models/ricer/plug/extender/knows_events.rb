module Ricer::Plug::Extender::KnowsEvents

  def self.included(base); base.extend(self); end
  
  def bot; Ricer::Bot.instance; end
  
  def all_subscriptions
    Ricer::Event.class_variable_defined?(:@@sl5_event_subscriptions) ?
      Ricer::Event.class_variable_get(:@@sl5_event_subscriptions) :
      Ricer::Event.class_variable_set(:@@sl5_event_subscriptions, {})
  end

  def event_subscriptions(event)
    all_subscriptions[event] ||= []
  end

  def subscribe(event, &block)
    bot.log_debug(display_subscribed(event, block))
    event_subscriptions(event).push(block)
  end

  def publish(event, *event_args)
    event_subscriptions(event).each do |subscription|
      bot.log_debug(display_publish_consumed(event, subscription))
      subscription.call(*event_args)
    end
  end

  def display_subscribed(event, subscription)
    "subscribe(#{event}) by #{subscription_location(subscription)}"
  end

  def display_publish_consumed(event, subscription)
    "publish(#{event}) consumed by #{subscription_location(subscription)}"
  end
  
  def subscription_location(subscription)
    sl = subscription.source_location
    file = sl[0].substr_from('/plugins/')
    line = sl[1]
    "#{file} #{line}"
  end

end
