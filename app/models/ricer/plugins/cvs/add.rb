module Ricer::Plugins::Cvs
  class Add < Ricer::Plugin
    
    trigger_is :add
    permission_is :voice
    
    has_setting name: :default_public, type: :boolean, scope: :bot,     permission: :responsible, default:false
    has_setting name: :default_delay,  type: :integer, scope: :user,    permission: :operator,    default:60, min:3, max:240
    has_setting name: :default_delay,  type: :integer, scope: :channel, permission: :operator,    default:60, min:3, max:240
    
    has_usage :execute, '<name> <url> [<boolean>] [<pubkey>]'
    
    def execute(name, url, public=nil, pubkey=nil)
      
      return rply :err_dup_name unless Repo.by_name(argv[0]).nil?
      return rply :err_dup_url unless Repo.by_url(argv[1]).nil?
      repo = Repo.new({
        user: user,
        name: name,
        url: url,
        public: public == nil ? get_setting(:default_public) : public,
        pubkey: pubkey,
      })
      repo.validate!
      Ricer::Thread.execute do
        begin
          system = System.new(repo, self, setting(:default_delay))
          system_name = system.detect
          return rply :err_system if system_name.nil?
          system = System.get_system(system_name).new(repo, self, setting(:default_delay))
          return rply :err_system if system.nil?
          repo.system = system_name
          repo.revision = system.revision
          repo.save!
          rply :msg_repo_added, name:repo.name, url:repo.url, type:repo.system
        rescue => e
          reply_exception e
        end
      end
    end
    
  end
end
