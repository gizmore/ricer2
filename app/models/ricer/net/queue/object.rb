# The QueueObject holds all messages to be sent for a user/channel
# Each message will add to the penalty, and queue the receiver more far behind in comparison to less chatty users
module Ricer::Net::Queue
  class Object
    
    attr_reader :lines
    
    MAX_WEIGHT ||= 2987654321 # Empty queue is not wanted to process at all
    
    WEIGHT_USER ||= 9
    WEIGHT_CHANNEL ||= 4
    WEIGHT_REDUCE ||= 10
    
    def initialize(to)
      @lines = []
      @penalty = 0
      @weight = to.class < Ricer::Irc::Channel ? WEIGHT_CHANNEL : WEIGHT_USER
    end
    
    def each
      @lines.each
    end
    
    def empty?
      @lines.empty?
    end
    
    def penalty
      @lines.empty? ? MAX_WEIGHT : @penalty
    end
    
    def push(line)
      @lines.push(line)
      @penalty += @weight
    end
    
    def flush
      @penalty -= @weight * @lines.length
      @penalty = [@penalty, 0].max
      @lines = []
    end
    
    def length
      @lines.length
    end
    
    def pop
      @lines.shift
    end
    
    def reduce_penalty
      @penalty = [@penalty - WEIGHT_REDUCE, 0].max
    end

  end
end
