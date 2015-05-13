module Ricer::Plugins::Todo
  class Solved < Ricer::Plugin
    trigger_is 'todo done'
    has_usage '<id>'
    def execute(id)

      entry = Model::Entry.search(id).first
      entry.deleted_at = Time.now
      entry.worker_id = sender.id
      entry.save!

      reply(entry.display_take())
      server.channels.each do |channel|
        channel.localize!.send_privmsg(entry.display_take())
      end

    end
  end
end
