###
### Prepend username to logfile lines
### 
module ActionPack::Foo

  # Implement this everywhere!
  def log_username
    '~Guest~'
  end
  
  def info(progname = nil, &block)
    if logger
      message = "[#{log_username}] "
      message += yield block
      logger.info(progname, message)
    end
#    ORIGINAL CODE
#    logger.info(progname, &block) if logger
#    EOC
  end

end
