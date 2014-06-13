module Ricer::Plugins::Gang
  class Game
    
    def self.loader; GangLoader.instance; end

    def self.semaphore; @semaphore ||= Semaphore.new; @semaphore; end
    def self.synchronized(&proc)
      semaphore.synchronized do
        yield proc
      end
    end
    
    def self.timed(constant_time=nil, &proc)
      before = Time.now.to_f
      yield proc
      elapsed = Time.now.to_f - before
      return elapsed if constant_time.nil?
      sleep(constant_time - elapsed)
    end
    
    def self.sleep(seconds)
      Kernel.sleep([seconds, 0].max)
    end

    ###################
    ### ClassLoader ###
    ################### 
    def self.race(name)
      loader.races[name.to_sym]
    end
    def self.gender(name)
      loader.genders[name.to_sym]
    end

  end
end
