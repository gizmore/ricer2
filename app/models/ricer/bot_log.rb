module Ricer
  class BotLog
    
    attr_accessor :failed
    
    def initialize
      @failed = false
      @logfiles = {
        debug: logger('debug'),
        info: logger('info'),
        warning: logger('warning'),
        error: logger('error'),
        fatal: logger('fatal'),
      }
    end
    
    def log_debug(msg); log('debug', msg); end
    def log_info(msg); log('info', msg); end
    def log_warn(msg); log('warn', msg); end
    def log_error(msg); log('error', msg); end
    def log_fatal(msg); log('fatal', msg); end
    def log_exception(e)
      log_fatal("#{e.class.name}: #{e.to_s}")
      e.backtrace.each do |line|
        log_fatal(line)
      end
      mail_exception(e)
    end
    
    # Mail first exception after a message
    def mail_exception(exception)
      return if @failed; @failed = true
      Ricer::Thread.execute do
        BotMailer.exception(exception).deliver
      end
    end
    
    def log(level, msg)
      msg = "[#{level.upcase}] #{msg}"
      puts msg
      @logfiles[level.to_sym].send(level, msg)
    end

    def logger(filename)
      begin
        filename = "#{Rails.root}/log/#{filename}"
        dir = File.dirname(filename)
        FileUtils.mkdir_p(dir) unless File.directory?(dir)
        Logger.new(filename)
      rescue => e
        puts "Cannot create logfile!"
        puts e
        puts e.backtrace.join("\n")
        mail_exception(e)
      end
    end
    
  end
end
