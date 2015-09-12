module Ricer::Plugins::Cvs
  class Cvs < Ricer::Plugin
    
    has_files
    
    def plugin_revision; 1; end

    def upgrade_1; plugin_dir_path; Repo.upgrade_1; Permission.upgrade_1; end
    # def upgrade_2; RepoUpdate.upgrade_2; end

    has_subcommand :abbo
    has_subcommand :abbos
    has_subcommand :add
    has_subcommand :list
    has_subcommand :unabbo
    
    def ricer_on_global_startup
      Ricer::Thread.execute do
        loop do
          Repo.working.each do |repo|
            sleep 15.seconds
            check_repo repo
          end
        end
      end
    end
    
    def check_repo(repo)
      begin
        bot.log_info("Cvs.check_repo(#{repo.url})")
        system = System.get_system(repo.system).new(repo, self, 10.seconds)
        updates = system.update(10)
        unless updates.empty?
          announce(repo, updates)
          repo.revision = updates[-1].revision
          repo.save!
        end
      rescue StandardError => e
        bot.log_exception e
      end
    end
    
    def announce(repo, updates)
      updates.each do |update|
        repo.abbonements.each do |abbonement|
          abbonement.target.localize!.send_privmsg(announce_msg(repo, update))
        end
      end
    end
    
    def announce_msg(repo, update)
      t :msg_announce, repo_name:repo.name, revision:update.display_revision, commiter:update.commiter, comment:update.comment, url: repo.revision_url(update.revision)
    end
    
  end
end
