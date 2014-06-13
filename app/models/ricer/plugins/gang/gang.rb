module Ricer::Plugins::Gang
  class Gang < Ricer::Plugin
    
    attr_reader :semaphore

    has_priority 10
    
    RSLEEP = 60.seconds
    USLEEP = 0.500.seconds

    trigger_is :g
    
    # Evil shortcut manipulation    
    has_setting name: :shortcut, scope: :user,    permission: :operator, type: :string, pattern: /^[-#,.!\"§$%&_<>x]$/, default: 'x'
    has_setting name: :shortcut, scope: :channel, permission: :operator, type: :string, pattern: /^[-#,.!\"§$%&_<>x]$/, default: 'x'
    def shortcut; get_setting(:shortcut); end
    def on_privmsg
      shortcut = self.shortcut
      unless shortcut == 'x'
        unless message.is_trigger_char?
          if (line[0] == shortcut)  && (line.index(' ') > 0)
            @message.args[1] = "#{@message.trigger_char}#{trigger} #{line[1..-1]}"
          end
        end
      end
    end
    
    def self.upgrade_0; end
    
    def on_init
      GangLoader.instance.load(self)
    end
    
    def ricer_on_global_startup
      recover_thread
      tick_thread
    end
    
    def recover_thread
      Ricer::Thread.execute do
        while true
          Game.timed(RSLEEP) do
            Player.online.each do |player|
              Game.synchronized do
#                Game.invoke(player, 'gang_on_recover')
              end
            end
          end
        end
      end
    end
    
    def tick_thread
      Ricer::Thread.execute do
        while true
          elapsed = Game.timed do
            Player.online.each do |player|
              Game.synchronized do
                timer_for(player)
              end
            end
          end
          Game.sleep(USLEEP - elapsed)
        end
      end
    end
    
    def timer_for(player)
      last = player.instance_variable_defined?(:@gang_last_tick) ? player.instance_variable_get(:@gang_last_tick) : nil
      now = Time.now.to_f
      player.instance_variable_set(:@gang_last_tick, now)
      return if last.nil?
      elapsed = now - last
      bot.log_debug "timer_for(#{player}) is lagging #{elapsed} elapsed"
      if player.moving?
        player.move_tick(elapsed)
      end
    end
  end    
end
