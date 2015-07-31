module Ricer::Plugins::Todo
  class Take < Ricer::Plugin
    trigger_is 'todo take'
    
    has_usage '<id>'
    def execute(id)
      take_entry(Model::Entry.find(id))
    end
    
    has_usage :take_by_text, '<text>'
    def take_by_text(description)
      take_entry(Model::Entry.search(description).first)
    end
    
    def take_entry(entry)
      if entry.nil?
        return raise ActiveRecord::RecordNotFound
      end
      if (entry.worker)
        rply(:err_already_taken, id: entry.id, worker: entry.worker.displayname)
      else
        entry.worker_id = sender.id
        entry.save!
        reply entry.display_take
        announce_todo_taken(entry)
      end
    end
    
    def announce_todo_taken(entry)
      announce = get_plugin("Todo/Announce")
      announce.announce_targets do |target|
        if target != user && target != channel
          target.localize!.send_privmsg(entry.display_take)
        end
      end
    end

  end
end
