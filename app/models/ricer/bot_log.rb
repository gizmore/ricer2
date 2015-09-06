module Ricer
  class BotLog
    
    PUTS_MUTEX = Mutex.new
    
    attr_reader   :log_level,   :put_level
    attr_accessor :log_enabled, :put_enabled, :mail_enabled

    LEVELS = [:debug, :info, :warn, :error, :fatal]
    
    ############
    ### Init ###
    ############    
    def initialize(log_level=:info, put_level=:debug)
      @mail_enabled = true
      @last_mail_time = 0
      @logfiles = {}
      LEVELS.each{|level| @logfiles[level] = logger(level) }
      self.log_level = log_level
      self.put_level = put_level
    end

    def logger(filename)
      begin
        filename = "#{Rails.root}/log/#{filename}"
        dir = File.dirname(filename)
        FileUtils.mkdir_p(dir) unless File.directory?(dir)
        Logger.new(filename)
      rescue StandardError => e
        throw Exception.new("Cannot create logfile!")
      end
    end

    #################
    ### Loglevels ###
    #################
    def valid_level(level); throw "Invalid PUTLEVEL: #{level}" unless valid_level?(level); level; end
    def valid_level?(level); !level || LEVELS.include?(level); end
    def log_level=(level); @log_level = valid_level(level); @log_enabled = !!level; @log_level; end
    def put_level=(level); @put_level = valid_level(level); @put_enabled = !!level; @put_level; end
    def has_put_level?(level); has_level?(level, @put_level) if @put_enabled; end
    def has_log_level?(level); has_level?(level, @log_level) if @log_enabled; end
    def has_level?(level, my_level); LEVELS.index(my_level) <= LEVELS.index(level); end

    ###############
    ### Helpers ###
    ###############
    def log_debug(msg); log(:debug, msg); end
    def log_info(msg); log(:info, msg); end
    def log_warn(msg); log(:warn, msg); end
    def log_error(msg); loge(:error, msg); end
    def log_fatal(msg); loge(:fatal, msg); end

    def log_exception(e)
      mail_exception(e) if @mail_enabled
      log_fatal("#{e.class.name}: #{e.to_s}")
      e.backtrace.each{|line|log_fatal(line)} if e.backtrace
    end
    
    ###############
    ### Silence ###
    ###############
    def silently(put_level=:warn, log_level=:warn, &block)
      # copy old levels
      log, put = @log_level, @put_level
      self.log_level = log_level; self.put_level = put_level
      # exec silently
      yield
      # restore old levels
      self.log_level = log; self.put_level = put
    end

    ############
    ### Mail ###
    ############    
    # Mail first exception after a message and some error-mail cooldown.
    def mail_exception(exception)
      unless mailed_recently?
        @last_mail_time = Time.now.to_i
        Ricer::Thread.execute {
          BotMailer.exception(exception).deliver
        }
      end
    end

    def mailed_recently?
      (Time.now.to_i - @last_mail_time) <= 30.seconds
    end

    ################
    ### Logwrite ###
    ################
    def loge(level, msg)
      log(level, msg, $stderr)
    end
    
    def log(level, msg, outstream=$stdout)
      msg = "[#{level.upcase}] #{msg}".force_encoding('utf-8')
      log_puts(msg, outstream) if has_put_level?(level)
      @logfiles[level].send(level, msg) if has_log_level?(level)
    end
    
    def log_puts(msg, outstream=$stdout)
      PUTS_MUTEX.synchronize { outstream.puts(msg) } if @put_enabled
    end

  end
end
