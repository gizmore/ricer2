module Ricer::Plugins::Art
  class Cowsay < Ricer::Plugin
    
    trigger_is :cowsay
    
    permission_is :halfop

    bruteforce_protected timeout: 12.seconds
    
    has_setting name: :image, type: :enum, scope: :user, permission: :halfop, enums:[:cat,:default], default: :cat
    
    has_usage :execute, '<..message..>'
    def execute(text)
      Ricer::Thread.execute do
        text = Shellwords.escape(text)
        reply `cowsay -f #{get_setting(:image)} -- #{text}`
      end
    end
    
  end
end
