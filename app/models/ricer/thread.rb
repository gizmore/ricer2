# Threadcount statistics
module Ricer
  class Thread < Thread
    
    @@peak = 1
    def self.peak; @@peak; end
    def self.count; list.length; end
      
    def initialize
      super
      now = Thread.list.length
      @@peak = now if now > @@peak
    end
    
    def self.bot; Ricer::Bot.instance; end 

    # Exception handling    
    def self.execute(&proc)
      bot.log_debug "Starting a thread"
      new do |t|
        begin
          yield proc
        rescue ActiveRecord::NoDatabaseError => e
          bot.running = false
        rescue Exception => e
          bot.log_exception(e)
        end
        bot.log_debug "Killed a thread"
      end
    end
    
  end
end
