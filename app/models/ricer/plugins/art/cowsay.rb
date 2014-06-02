module Ricer::Plugins::Art
  class Cowsay < Ricer::Plugin
    
    trigger_is :cowsay
    
    permission_is :halfop

    bruteforce_protected
    
    has_setting name: :image, type: :enum, scope: :user, permission: :halfop, enums:[:cat,:default], default: :cat
    
    has_usage :execute, '[<..message..here..>]'
    
    def execute(text)
      byebug
      text = Shellwords.escape(text)
      Ricer::Thread.execute do
        out = Kernel.exec("cowsay -f #{get_setting(:image)} -- #{text}")
        puts out
        puts out.inspect
      end
    end
    
  end
end
