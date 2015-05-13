module Ricer::Plugins::Todo
  class Add < Ricer::Plugin
    
    trigger_is 'todo add'
    
    abbonementable_by([Ricer::Irc::User, Ricer::Irc::Channel])

    has_usage '<..string..>'
    def execute(todo_text)
      entry = Ricer::Plugins::Todo::Model::Entry.new({
        text: todo_text,
        creator_id: sender.id,
        priority: 0,
      })
      entry.save!
      reply(entry.display_item(entry.id))
      byebug
      servers.each do |server|
        server.channels.each do |channel|
          channel.localize!.send_privmsg(entry.display_item(entry.id))
        end
      end
    end
  end
end
