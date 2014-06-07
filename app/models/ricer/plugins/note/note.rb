module Ricer::Plugins::Note
  class Note < Ricer::Plugin

    def upgrade_1; Message.upgrade_1; end
    
    trigger_is :notes

    has_subcommand :list
    has_subcommand :send
    has_subcommand :sent
    has_subcommand :unread
    
    def on_join
      deliver_messages unless user.registered?
    end
    
    def ricer_on_user_authenticated
      deliver_messages
    end
    
    private
    
    def unread
      Ricer::Plugins::Note::Message.uncached do
        Ricer::Plugins::Note::Message.inbox(user).unread.count
      end
    end
    
    def deliver_messages
      count = unread
      user.send_message(t(:msg_new_notes, count: count)) if count > 0
    end

  end
end
