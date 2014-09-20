module Ricer
  class BotLog
    
    PUTS_MUTEX = Mutex.new
    
    def initialize
      @last_mail_time = 0
      @logfiles = {
        debug: logger('debug'),
        info: logger('info'),
        warning: logger('warning'),
        error: logger('error'),
        fatal: logger('fatal'),
      }
    end
    
    def log_debug(msg); log(:debug, msg); end
    def log_info(msg); log(:info, msg); end
    def log_warning(msg); log(:warning, msg); end
    def log_error(msg); log(:error, msg); end
    def log_fatal(msg); log(:fatal, msg); end
    def log_exception(e)
      log_fatal("#{e.class.name}: #{e.to_s}")
      e.backtrace.each{|line|log_fatal(line)} if e.backtrace
      mail_exception(e)
    end
    
    # Mail first exception after a message
    def mail_exception(exception)
      return if (Time.now.to_i - @last_mail_time) < 30
      @last_mail_time = Time.now.to_i
      Ricer::Thread.execute do |t|
        BotMailer.exception(exception).deliver
      end
    end
    
    def log_puts(msg)
      PUTS_MUTEX.synchronize do
        puts msg
      end
    end
    
    def log(level, msg)
      msg = "[#{level.upcase}] #{msg}".force_encoding('utf-8')
      log_puts(msg)
      @logfiles[level].send(level, msg)
    end

    def logger(filename)
      begin
        filename = "#{Rails.root}/log/#{filename}"
        dir = File.dirname(filename)
        FileUtils.mkdir_p(dir) unless File.directory?(dir)
        Logger.new(filename)
      rescue => e
        raise Exception.new("Cannot create logfile!")
      end
    end
    
  end
end
