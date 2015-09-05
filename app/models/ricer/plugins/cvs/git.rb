module Ricer::Plugins::Cvs
  class Git < System
    
    include Open4
    
    @loading = false
    
    def working?
      checkout
    end
    
    def clone_cmd; "git clone --progress #{repo.url_arg} #{repo.dir_arg}"; end
    def update_cmd; "cd #{repo.dir_arg} && git pull"; end
    def revision_cmd; "cd #{repo.dir_arg} && git rev-parse HEAD"; end
    
    def revision
      begin
        out = `#{revision_cmd}`
        out.strip
      rescue StandardError => e
        nil
      end
    end
    
    # def setup_credentials
      # user = (repo.username||'no')
      # pass = (repo.password||'no')
      # host = (repo.uri.hostname)
      # credentials = "machine #{host} login #{user} password #{pass}"
      # `chmod 0600 ~/.netrc`
      # `rm ~/.netrc`
      # `echo #{credentials} > ~/.netrc`
      # `chmod 0400 ~/.netrc`
    # end
    
    def self.loading?
      @loading
    end
    
    def self.loading=(bool)
      @loading = bool
    end
    
    def checkout
      
      return nil if self.class.loading?
      
      self.class.loading = true
      
      status = Open4::popen4(clone_cmd) do |pid, stdin, stderr, stdout|

        stdin.close
        errbuf = AsciiControlBuffer.new(stderr)
        outbuf = AsciiControlBuffer.new(stdout)
        
        begin
          
          while outbuf.waiting? || errbuf.waiting?
            
            if outbuf.read
              reply outbuf.to_s
            end
            
            if errbuf.read
              @plugin.reply errbuf.to_s
            end
            
          end
        rescue StandardError => e
          bot.log_exception(e)
          @plugin.reply_exception(e)
          result = false
        end
      end

      # Last line
      finalize

      self.class.loading = false

      status.to_i == 0
    end
    
    def update(max_updates)
      
      updated = true
      result = []

      status = Open4::popen4(update_cmd) do |pid, stdin, stderr, stdout|
        
        stdin.close
        errbuf = AsciiControlBuffer.new(stderr)
        outbuf = AsciiControlBuffer.new(stdout)
        begin
          while outbuf.waiting? || errbuf.waiting?
            if outbuf.read
              puts outbuf.to_s
            end
            if errbuf.read
              puts errbuf.to_s
              if errbuf.to_s.index('Already up-to-date') != nil
                updated = false
              end
            end
          end
        rescue StandardError => e
          bot.log_exception(e)
          result = false
        end
      end
      
      return result if updated == false
      
      n = 1
      begin
        while true # old_revision != next_revision
          repo_update = get_update(n)
          break if repo_update.nil?
          break if repo_update.revision == repo.revision
          break if repo_update.revision == result[0].revision if result[0]
          break if n >= (max_updates)
          result.unshift(repo_update)
          n = n + 1
        end
      rescue StandardError => e
        bot.log_exception(e)
      end
      result
    end
    
    private
    def get_update(n)
      command = "cd #{repo.dir_arg} && git --no-pager log --reverse --format=medium -#{n} | head -n 8"
      out = `#{command}`
      out = out.split("\n")
      revision = commiter = comment = date = nil
      out.each do |line|
        if line.empty? or line.start_with?('Merge: ')
          # skipper
        elsif line.start_with?('commit')
          revision = line.substr_from('commit').trim
        elsif line.start_with?('Author:')
          commiter = line.substr_from('Author:').trim
        elsif line.start_with?('Date:')
          date = DateTime.parse(line.substr_from('Date:').trim)
        elsif line.start_with?(' ')
          comment = line.trim
        end
        break if revision and commiter and comment and date
      end
      if revision and commiter and comment and date
        return RepoUpdate.new(revision, commiter, date, comment)
      end
      return nil
    end
    
  end
end
