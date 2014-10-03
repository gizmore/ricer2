module Ricer
  class BotLog
    
    PUTS_MUTEX = Mutex.new

    ############
    ### Init ###
    ############    
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
    def logger(filename)
      begin
        filename = "#{Rails.root}/log/#{filename}"
        dir = File.dirname(filename)
        FileUtils.mkdir_p(dir) unless File.directory?(dir)
        Logger.new(filename)
      rescue StandardError => e
        raise Exception.new("Cannot create logfile!")
      end
    end
    
    ###############
    ### Helpers ###
    ###############
    def log_debug(msg); log(:debug, msg); end
    def log_info(msg); log(:info, msg); end
    def log_warning(msg); log(:warning, msg); end
    def log_error(msg); loge(:error, msg); end
    def log_fatal(msg); loge(:fatal, msg); end

    def log_exception(e)
      mail_exception(e)
      log_fatal("#{e.class.name}: #{e.to_s}")
      e.backtrace.each{|line|log_fatal(line)} if e.backtrace
    end

    ############
    ### Mail ###
    ############    
    # Mail first exception after a message and some error-mail cooldown.
    def mail_exception(exception)
      if((Time.now.to_i - @last_mail_time) >= (30.seconds))
        @last_mail_time = Time.now.to_i
        Ricer::Thread.execute {
          BotMailer.exception(exception).deliver
        }
      end
    end

    ################
    ### Logwrite ###
    ################
    def log(level, msg, outstream=$stdout)
      msg = "[#{level.upcase}] #{msg}".force_encoding('utf-8')
      log_puts(msg, outstream)
      @logfiles[level].send(level, msg)
    end
    
    def loge(level, msg)
      log(level, msg, $stderr)
    end
    
    def log_puts(msg, outstream=$stdout)
      PUTS_MUTEX.synchronize {
        outstream.puts msg
      }
    end

  end
end
