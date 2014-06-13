module Ricer::Plugins::Music
  class Audacious < Ricer::Plugin
    
    trigger_is :audacious, :announce => true

    has_setting name: :announce, scope: :user,    permission: :halfop, type: :boolean, default: false
    has_setting name: :announce, scope: :channel, permission: :halfop, type: :boolean, default: false

    has_usage :execute, '<boolean>'
    def execute(boolean)
      boolean = boolean ? '1' : '0'
      methodn = @message.is_query? ? 'confu' : 'confc'
      exec_line("#{methodn} audacious announce #{boolean}")
    end
    
    def ricer_on_global_startup
      Ricer::Thread.execute do
        @@current_song = what_audacious_is_playing
        while true
          sleep 5.seconds
          check_new_song
        end
      end
    end
    
    def what_audacious_is_playing
      back = `audtool current-song`
      back.strip.gsub(/\s+/, ' ')
    end
    
    def check_new_song
      current_song = what_audacious_is_playing
      if @@current_song != current_song
        @@current_song = current_song
        announce_new_song
      end
    end
    
    def announce_new_song
      Ricer::Irc::Channel.online.each do |channel|
        if get_channel_setting(channel, :announce)
          channel.localize!.send_privmsg(announce_message)
        end
      end
      Ricer::Irc::User.online.each do |user|
        if get_user_setting(user, :announce)
          user.localize!.send_privmsg(announce_message)
        end
      end
    end
    
    def announce_message
      I18n.t('ricer.plugins.music.audacious.msg_next_song', who: 'gizmore', song: @@current_song)      
    end
    
  end
end
