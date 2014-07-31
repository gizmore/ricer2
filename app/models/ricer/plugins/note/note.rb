module Ricer::Plugins::Note
  class Note < Ricer::Plugin

    def plugin_revision; 2; end
    def upgrade_1; Message.upgrade_1; end
    def upgrade_2; Message.upgrade_2; end
    
    trigger_is :notes

    has_subcommand :list
    has_subcommand :send
    has_subcommand :sent
    has_subcommand :unread
    
    def ricer_on_user_loaded
      deliver_messages unless Ricer::Irc::User.current.registered?
    end
    
    def ricer_on_user_authenticated
      deliver_messages
    end
    
    private
    
    def unread
      Ricer::Plugins::Note::Message.uncached do
        Ricer::Plugins::Note::Message.inbox(Ricer::Irc::User.current).unread.count
      end
    end
    
    def deliver_messages
      count = unread
      Ricer::Irc::User.current.send_message(t(:msg_new_notes, count: count)) if count > 0
    end

  end
end
