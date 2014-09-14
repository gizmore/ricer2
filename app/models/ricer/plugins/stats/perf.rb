module Ricer::Plugins::Stats
  class Perf < Ricer::Plugin
    include ActionView::Helpers::NumberHelper

    trigger_is :perf
    
    has_setting name: :total_uptime, scope: :bot, type: :duration, permission: :responsible
    
    def on_init
      @@start = Time.now
      @@max_memory = 0
      @@max_mem_time = Time.now
      memory_peak
    end
    
#    subscribe('ricer/on/exit') do |bot|
#      increase_setting(:total_uptime, :bot, uptime)
#    end

    def ricer_on_trigger
      memory_peak
    end
    
    def memory; OS.rss_bytes * 1024; end
    def memory_peak
      mem = memory
      if mem >= @@max_memory
        @@max_memory = mem
        @@max_mem_time = Time.now
      end
      mem
    end
    
    def uptime
      Time.now - @@start
    end
    
    def total_uptime
      get_setting(:total_uptime) + uptime
    end
    
    has_usage
    def execute
      memory = memory_peak
      queries = ActiveRecord::ConnectionAdapters::AbstractAdapter.querycount
      rply :perf,
        uptime: display_uptime, total_uptime: display_total_uptime,
        queries: queries, qps: number_with_precision(queries/uptime.to_f, :precision => 2),
        threads: Ricer::Thread.count, max_threads: Ricer::Thread.peak,
        memory: number_to_human_size(memory), max_memory: number_to_human_size(@@max_memory),
        pid: Process.pid, cpu: display_cpu_usage
    end
    
    private

    def display_cpu_usage
      number_with_precision(cpu_usage, precision:2)
    end
    
    def display_uptime
      lib.human_duration(uptime)
    end
    
    def display_total_uptime
      lib.human_duration(total_uptime)
    end
    
    def cpu_usage
      if OS.posix?
        `ps -o %cpu= -p #{Process.pid}`.to_f
      else
        "?.??(Win)"
      end
    end
    
  end
end
