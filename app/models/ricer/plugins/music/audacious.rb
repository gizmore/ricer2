module Ricer::Plugins::Music
  class Audacious < Ricer::Plugin
    
    is_announce_trigger :audacious
    
    default_enabled false
    
    def ricer_on_global_startup
      Ricer::Thread.execute do
        # Init
        @@current_song = what_audacious_is_playing if get_setting(:trigger_enabled)
        sleep 15.seconds
        # Threadloop
        while true
          if get_setting(:trigger_enabled)
            # Announce every 5 seconds
            check_new_song
            sleep 8.seconds
          else
            # Wait for activation
            sleep 40.seconds
          end
        end
      end
    end
    
    def what_audacious_is_playing
      back = `audtool current-song`
      back.strip.gsub(/\s+/, ' ') rescue nil
    end
    
    def check_new_song
      current_song = what_audacious_is_playing
      if @@current_song != current_song
        @@current_song = current_song
        announce_new_song
      end
    end
    
    def announce_new_song
      announce_targets do |target|
        target.localize!.send_privmsg(announce_message)
      end
    end
    
    def announce_message
      I18n.t('ricer.plugins.music.audacious.msg_next_song', who: 'gizmore', song: @@current_song)      
    end
    
  end
end
