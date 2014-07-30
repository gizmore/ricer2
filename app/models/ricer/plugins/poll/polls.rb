module Ricer::Plugins::Poll
  class Polls < Ricer::Plugin
    
    is_list_trigger :polls, :for => Ricer::Plugins::Poll::Question.closed
    
  end
end
