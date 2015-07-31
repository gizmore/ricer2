module Ricer::Plugins::Todo
  class Done < Ricer::Plugin
    trigger_is 'todo done'
    has_usage '<id>'
    def execute(id)
      solve_todo_entry(Model::Entry.find(id))
    end
    
    def solve_todo_entry(entry)
      return rply(:err_already_done, worker: entry.worker.displayname, id: entry.id) unless entry.done_at.nil?
      entry.done_at = Time.now
      entry.worker_id = sender.id
      entry.save!
      rply :msg_done,
        id: entry.id,
        creator: entry.creator.displayname,
        worker: entry.worker.displayname,
        text: entry.text,
        time: entry.displaytime
      announce_todo_done(entry)
    end
    
    def announce_todo_done(entry)
      announce = get_plugin("Todo/Announce")
      announce.announce_targets do |target|
        if target != user && target != channel
          target.localize!.send_privmsg(entry.display_take)
        end
      end
    end
    
  end
end
