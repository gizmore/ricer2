module Ricer::Plugins::Poll
  class Newpolls < Ricer::Plugin
    
    is_list_trigger :newpolls, :for => Ricer::Plugins::Poll::Question.open

  end
end
