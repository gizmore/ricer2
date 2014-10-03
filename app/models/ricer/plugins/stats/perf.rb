module Ricer::Plugins::Stats
  class Perf < Ricer::Plugin

    trigger_is :perf
    
    def plugin_init
      bot.log_debug("Stats/Perf#plugin_init")
      @@max_memory = 0
      @@max_mem_time = Time.now
      memory_peak
    end
    
    def memory
      OS.rss_bytes * 1024
    end

    def ricer_on_trigger
      memory_peak
    end
    
    def memory_peak
      mem = memory
      if mem >= @@max_memory
        @@max_memory = mem
        @@max_mem_time = Time.now
      end
      bot.log_debug("Stats/Perf#memory_peak is at #{@@max_memory}")
      mem
    end
    
    has_usage
    def execute
      memory = memory_peak
      adapter = ActiveRecord::ConnectionAdapters::AbstractAdapter
      queries = adapter.querycount
      db_time = adapter.querytime
      pool_now = 10
      pool_max = 10
      pool_peak = 10
      rply(:perf,
        queries: queries, qps: lib.human_fraction(queries/bot.uptime.to_f, 2),
        db_time: lib.human_duration(db_time), uptime: lib.human_duration(bot.uptime),
        pool_now: pool_now, pool_peak: pool_peak, pool_max: pool_max,
        threads: Ricer::Thread.count, max_threads: Ricer::Thread.peak,
        memory: lib.human_filesize(memory), max_memory: lib.human_filesize(@@max_memory),
        pid: Process.pid, cpu: lib.human_fraction(cpu_usage, 2),
      )
    end
    
    def cpu_usage
      OS.posix? ? `ps -o %cpu= -p #{Process.pid}`.to_f : "?.??(Win)"
    end
    
  end
end
