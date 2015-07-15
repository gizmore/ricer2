module Ricer::Plugins::Cvs
  class System
    
    attr_reader :repo, :plugin
    
    SYSTEMS = [:Git, :Svn]

    def initialize(repo, plugin, delay=2.0)
      @repo = repo
      @plugin = plugin
      @reply = Ricer::Plug::PlugProc.new(plugin, delay)
    end
    
    def bot
      Ricer::Bot.instance
    end

    def get_system(name); self.class.get_system(name); end
    def self.get_system(name); Ricer::Plugins::Cvs.const_get(name); end
    
    def detect
      repo.rmdir
      SYSTEMS.each do |name|
        result = get_system(name).new(@repo, @plugin).working?
        return nil if result.nil?
        return name if result
        repo.rmdir
      end
      nil
    end
    
    def reply(message)
      @reply.reply(message)
    end
    
    def finalize
      @reply.finalize
    end
    
    ################
    ### Abstract ###
    ################
    def working?; stub('working?'); end
    def checkout; stub('checkout'); end
    def revision; stub('revision'); end
    def update(max_updates); stub('update'); end

    private
    def stub(name)
      throw "System #{self.class.name} does not implement #{name}!"
    end    
    
  end
end
