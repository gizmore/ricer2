module Ricer::Plugins::Poll
  class Showpoll < Ricer::Plugin
    
    is_show_trigger :showpoll, :for => Ricer::Plugins::Poll::Question.closed

  end
end
