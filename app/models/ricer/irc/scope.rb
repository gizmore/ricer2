module Ricer::Irc
  class Scope
  
    attr_reader :char, :bit, :name
  
    def initialize(hash)
      hash.each { |name, value| instance_variable_set("@#{name}", value) }
    end
    
    # Trigger scopes
    USER       = new(char:'u', bit:0x08000000, :name => :user)
    CHANNEL    = new(char:'c', bit:0x04000000, :name => :channel)
    EVERYWHERE = new(char:'e', bit:0x0C000000, :name => :everywhere)
    # Additional Setting scopes
    BOT        = new(char:'b', bit:0x02000000, :name => :bot)    # For settings only
    SERVER     = new(char:'s', bit:0x01000000, :name => :server) # For settings only
    ALL        = new(char:'a', bit:0x0F000000, :name => :all)    # For settings only
    @@all = { user:USER, channel:CHANNEL, everywhere:EVERYWHERE, bot:BOT, server:SERVER, all:ALL }

    def self.by_arg(arg)
      self.by_name(arg) || self.by_label(arg)
    end

    def self.by_name(name)
      @@all[name]
    end

    def self.by_name!(name)
      by_name(name) or raise RuntimeError.new("Invalid scope: #{name}")
    end

    def self.by_label(name)
      name.downcase!
      @@all.each do |sc|
        return sc if sc.to_label.downcase == name
      end
      nil
    end
    
    def in_scope?(scope); (scope.bit & self.bit) > 0; end
    def to_label; I18n.t('ricer.irc.scope.'+self.char); end
    def to_usage_label; I18n.t('ricer.irc.scope.usage.'+self.char); end
    
    def everywhere?; self.bit == EVERYWHERE.bit; end
    def channel?; self.bit == CHANNEL.bit; end
    def private?; self.bit == USER.bit; end

    def self.matching?(scope, scopes, channel)
      #scope = :bot if scope.nil?
      bit = self.by_name(scope).bit
      Array(scopes).each do |sa|
        if (sa.to_sym != :channel && scope.to_sym != :channel) || (channel != nil)
          if (self.by_name(sa).bit & bit) > 0
            return true
          end
        end
      end
      false
    end
    
  end
end
