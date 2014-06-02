module Ricer::Plugins::Cvs
  class Find < Ricer::Plugin
    
    def execute
      repo = Repo.by_arg(argv[0])
      return rplyp :err_repo if repo.nil?
      return rplyp :err_perm unless repo.readable_by?(user)
      
      Ricer::Thread.execute do
        
        arg = Shellwords.escape(argv[1])
        result = `find #{repo.dir_arg} -name #{arg}`
        
      end

    end
    
  end
end
