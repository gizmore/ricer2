module Ricer::Plugins::Todo
  class Add < Ricer::Plugin
    
    trigger_is 'todo add'
    
    has_usage '<..string..>'
    def execute(todo_text)
      entry = Ricer::Plugins::Todo::Model::Entry.new({
        text: todo_text,
        creator_id: sender.id,
        priority: 0,
      })
      entry.save!
      reply(entry.display_item(entry.id))
      announce_new_todo(entry)
    end
    
    def announce_new_todo(entry)
      announce = get_plugin("Todo/Announce")
      announce.announce_targets do |target|
        if target != user && target != channel
          target.localize!.send_privmsg(entry.display_item(entry.id))
        end
      end
    end

  end
end
