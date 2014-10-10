# Threadcount statistics
module Ricer
  class Thread < Thread
    
    extend Ricer::Base::BaseExtend
    
    @@limits = {} # Number of jobs per user
    @@mutex = Mutex.new # Mutex for guid counter

    @@peak = 1; def self.peak; @@peak; end # Performance peak counter
    def self.count; list.length; end # Performance currently running

    @@fork_counter = 2 # Global execution calls counter / fork_count
      
    def initialize
      super
      now = Thread.list.length
      @@peak = now if now > @@peak
    end
    
    ####################################
    ### Debug and Exception handling ###
    ####################################
    def self.display_proc(proc)
      (file, line = *proc.source_location) or raise RuntimeError.new("No sourcecode line for proc.")
      "#{file} #{line}"
    end

    def self.execute(&proc)
      # Message that we copy into the new thread
      old_message = Thread.current[:ricer_message]
      # Sender to count threads
      sender = old_message.sender if old_message && old_message.sender.is_a?(Ricer::Irc::User)
#     sender = old_message.sender if old_message && old_message.plugin && old_message.sender.is_a?(Ricer::Irc::User)
      check_thread_limits!(sender) if sender
      old_message.forked! if old_message && old_message.plugin
      # Start thread
      new do |t|
        # copy the network message
        Thread.current[:ricer_message] = old_message 
        # Count global thread counter up, for debugging purposes
        guid = 0
        @@mutex.synchronize do
          @@fork_counter += 1
          guid = @@fork_counter
          if sender
            @@limits[sender] ||= 0
            @@limits[sender] += 1
          end
        end
        # Try to exec
        begin
          bot.log_debug "[#{guid}] Started thread at #{display_proc(proc)}"
          yield proc
          bot.log_debug "[#{guid}] Stopped thread at #{display_proc(proc)}"
        rescue StandardError => e
          bot.log_exception(e)
          bot.log_debug "[#{guid}] Killed thread at #{display_proc(proc)}"
        # rescue StandardError => e
          # bot.log_debug "[#{guid}] Killed thread at #{display_proc(proc)}"
        ensure
          if sender; record_user_thread_limits(sender, -1); end
          if old_message && old_message.plugin
            old_message.joined!
            #bot.log_debug("JOINED THREAD!")
            if old_message.forked?
              #bot.log_debug("STILL SOMETHING TODO!")
            elsif old_message.pipe?
              #bot.log_debug("PIPING OUTPUT!")
              old_message.pipe!
            elsif old_message.chained?
              #bot.log_debug("CHAINING!")
              old_message.chain!
            else
              #bot.log_debug("EXECUTION DONE!")
              old_message.plugin.process_event('ricer_after_execution')
            end
          end
        end
      end
      
    end
    
    def self.record_user_thread_limits(user, add=1)
      @@mutex.synchronize do
        @@limits[user] += add
      end
    end

    def self.may_spawn_threads?(user)
      @@limits[user].nil? || @@limits[user] < 3
    end
    
    def self.has_threads_exceeded?(user)
      !may_spawn_threads?(user)
    end
    
    def self.check_thread_limits!(user)
      if has_threads_exceeded?(user)
        raise Ricer::ExecutionException.new(I18n.t('ricer.err_thread_limit', count: 3))
      end
    end

  end
end
