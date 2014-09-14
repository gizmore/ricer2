module Ricer::Plugins::Cvs
  class Cvs < Ricer::Plugin
    
    def upgrade_1; Repo.upgrade_1; Permission.upgrade_1; end

    has_subcommand :abbo
    has_subcommand :abbos
    has_subcommand :add
    has_subcommand :list
    has_subcommand :unabbo
    
    def ricer_on_global_startup
      Ricer::Thread.execute do
        while true
          sleep 15.seconds
          Repo.working.each do |repo|
            check_repo repo
            sleep 15.seconds
          end
        end
      end
    end
    
    def check_repo(repo)
#      begin
        system = System.get_system(repo.system).new(repo, self, 10.seconds)
        updates = system.update
        unless updates.empty?
          announce(repo, updates)
          repo.revision = updates[-1].revision
          repo.save!
        end
#      rescue => e
#        bot.log_exception e
#      end
    end
    
    def announce(repo, updates)
      updates.each do |update|
        repo.abbonements.each do |abbonement|
          abbonement.target.localize!.send_privmsg(announce_msg(repo, update))
        end
      end
    end
    
    def announce_msg(repo, update)
      t :msg_announce, repo_name:repo.name, revision:update.display_revision, commiter:update.commiter, comment:update.comment
    end
    
  end
end
