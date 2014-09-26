module Ricer::Plugins::Art
  class Cowsay < Ricer::Plugin
    
    trigger_is :cowsay
    
    permission_is :halfop

    bruteforce_protected timeout: 12.seconds
    
    has_setting name: :image, type: :enum, scope: :user, permission: :halfop, enums: [:cat,:default], default: :cat
    
    has_usage '<..text..>'
    def execute(text)
      Ricer::Thread.execute do
        text = Shellwords.escape(text)
        response = `cowsay -f #{get_setting(:image)} -- #{text}`
        return rply :err_no_cowsay if response.nil?
        reply response
      end
    end
    
  end
end
