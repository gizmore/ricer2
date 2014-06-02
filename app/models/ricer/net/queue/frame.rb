# The QueueFrame controls the send rate limit for a server
# The send rate for a server can be adjusted with server.throttle
# This class also calculates how long to sleep for the sending thread for the next messages
module Ricer::Net::Queue
  class Frame
    
    SECONDS = 3.0
    MIN_SLEEP = 0.15
    
    def initialize(server)
      @server = server
      @timestamps = []
    end
    
    # Mark a message has been sent in the frame
    def sent
      @timestamps.push(Time.now.to_f)
    end
    
    # Triggering flood?
    def exceeded?
      @timestamps.count >= @server.throttle
    end
    
    # Calculate sleeptime
    def sleeptime
      cleanup
      return MIN_SLEEP unless exceeded?
      [MIN_SLEEP + @timestamps[-@server.throttle] - frame_start, MIN_SLEEP].max
    end
    
    private

    # Start of the timeframe to observe
    def frame_start
      Time.now.to_f - SECONDS
    end
    
    # Clean older marks
    def cleanup
      cut = frame_start
      while @timestamps.count > 0
        if @timestamps[0] < cut
          @timestamps.shift
        else
          break
        end
      end
    end
    
  end
end
