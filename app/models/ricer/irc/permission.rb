module Ricer::Irc
  class Permission
    
    include Ricer::Base::Base
    
    attr_reader :priv, :symbol, :char, :bit, :name, :modeable, :hierarchic, :authenticated
    
    def initialize(hash); hash.each { |name, value| instance_variable_set("@#{name}", value) }; end

    def modeable?; @modeable; end
    def hierarchical?; @hierarchic; end
    def authenticated=(bool); @authenticated = bool; end 

    PUBLIC ||=        new(priv:'p', symbol:'',  char:'',  bit:0x0000,  :name => :public,        :modeable => false, :hierarchic => true,  :authenticated => false)
    REGISTERED ||=    new(priv:'r', symbol:'',  char:'',  bit:0x0001,  :name => :registered,    :modeable => false, :hierarchic => false, :authenticated => false)
    AUTHENTICATED ||= new(priv:'l', symbol:'',  char:'',  bit:0x0002,  :name => :authenticated, :modeable => false, :hierarchic => false, :authenticated => false)
    VOICE ||=         new(priv:'v', symbol:'+', char:'v', bit:0x0004,  :name => :voice,         :modeable => true,  :hierarchic => true,  :authenticated => false)
    HALFOP ||=        new(priv:'h', symbol:'%', char:'h', bit:0x0008,  :name => :halfop,        :modeable => true,  :hierarchic => true,  :authenticated => false)
    OPERATOR ||=      new(priv:'o', symbol:'@', char:'o', bit:0x0010,  :name => :operator,      :modeable => true,  :hierarchic => true,  :authenticated => false)
    MODERATOR ||=     new(priv:'m', symbol:'',  char:'',  bit:0x0020,  :name => :moderator,     :modeable => true,  :hierarchic => false, :authenticated => false)
    STAFF ||=         new(priv:'s', symbol:'',  char:'',  bit:0x0040,  :name => :staff,         :modeable => true,  :hierarchic => false, :authenticated => false)
    ADMIN ||=         new(priv:'a', symbol:'',  char:'',  bit:0x0080,  :name => :admin,         :modeable => true,  :hierarchic => false, :authenticated => false)
    FOUNDER ||=       new(priv:'f', symbol:'~', char:'~', bit:0x0100,  :name => :founder,       :modeable => true,  :hierarchic => true,  :authenticated => false)
    IRCOP ||=         new(priv:'i', symbol:'!', char:'!', bit:0x0200,  :name => :ircop,         :modeable => true,  :hierarchic => true,  :authenticated => false)
    OWNER ||=         new(priv:'x', symbol:'',  char:'',  bit:0x0400,  :name => :owner,         :modeable => true,  :hierarchic => false, :authenticated => false)
    RESPONSIBLE ||=   new(priv:'y', symbol:'',  char:'',  bit:0x0800,  :name => :responsible,   :modeable => false, :hierarchic => false, :authenticated => false)
    ALL ||= [ PUBLIC, REGISTERED, AUTHENTICATED, VOICE, HALFOP, OPERATOR, MODERATOR, STAFF, ADMIN, FOUNDER, IRCOP, OWNER, RESPONSIBLE ]
    def self.all_granted(authenticated=true); by_permission(0x0800, authenticated); end
    
    def self.all_symbols
      back = ''
      ALL.each do |p|; back += p.symbol; end
      back
    end
      
    def to_s
      super + " Ricer::Irc::Priviledge(#{self.priv})"
    end
    
    def to_label
      I18n.t("ricer.irc.permission.#{self.name}")
    end
    
    def display(respect_auth=REGISTERED)
      out = '';
      bits = self.all_bits(respect_auth)
      ALL.each do |p|
        if ((p.bit & bits) > 0) || (p.bit == 0)
          out += "\x02#{p.priv}\x02"
        else #elsif (p.bit & self.bit) > 0
          out += p.priv
        end
      end
      out
    end
    
    def self.valid?(name)
      self.by_name(name) != nil
    end
    
    def self.by_char(char)
      char = char.to_s.downcase
      ALL.each{|p| return p if p.priv == char }
      nil
    end
    
    def self.by_name(name)
      name = name.to_s.downcase.to_sym
      ALL.each{|p| return p if p.name == name }
      nil
    end

    def self.by_name!(name)
      by_name(name) or raise RuntimeError.new("Unknown permission: #{name}")
    end
    
    def self.by_label(label)
      label = label.to_s.downcase
      ALL.each do |p|
        return p if p.to_label.downcase == label
      end
      nil
    end
    
    def self.bits_from_nickname(nickname)
      bits_from_symbols(nickname)
    end
    
    def self.bits_from_symbols(symbols)
      bits = 0
      ALL.each do |p|
        bits |= p.bit if (p.symbol != '') && (symbols.include?(p.symbol))
      end
      bits
    end

    def self.by_arg(arg)
      negate = arg.to_s[0] == '-'
      arg = arg.to_s.ltrim('+-')
      permission = self.by_name(arg) || self.by_label(arg)
      return nil if permission.nil?
      return negate ? 
        permission.negated :
        permission
    end
    
    def negated
      gotit = false
      ALL.reverse.each do |p|
        return p if gotit
        gotit = p if p.bit == self.bit
      end
      PUBLIC
    end
    
    def self.by_permission(permissions, authenticated=false)
      #bot.log_debug("Permission#by_permission(#{permissions}) AUTHED: #{authenticated}")
      priv = 'p'
      symbol = ''
      char = ''
      bit = 0
      name = :public
      ALL.each do |p|
        if (p.bit & permissions) > 0
          priv += p.priv
          symbol = p.symbol unless p.symbol.empty?
          char = p.char unless p.char.empty?
          bit |= p.bit
          name = p.name
        end
      end
      new({priv: priv, symbol: symbol, char: char, bit: bit, name: name, modeable: false, hierarchical: false, authenticated: authenticated})
    end
    
    def merge(permission)
      self.class.by_permission(permission.bits | self.bits, self.authenticated)
    end
    
    def substract(permission)
      self.class.by_permission(permission.bits & self.bits, self.authenticated)
    end

    def bits
      sumbits = 0; ALL.map{|p| sumbits |= p.bit if self.bit >= p.bit }; sumbits
    end
    
    # Compute the hierarchic bits from this permission bitobject, like voice, halfop, op.
    # These can be topped in permission checks by higher bits like ircop or admin.
    #
    # @param respect_auth [Permission] the authenticated permissions to filter with. E.g.: Permission::ALL, Permission::REGISTERED
    # @return [Integer] the computed bitmask.
    def hierarchic_bits(respect_auth=REGISTERED)
      sumbits = 0
      ALL.map{|p| sumbits += p.bit if (self.bit >= p.bit) && p.hierarchic }
      sumbits &= respect_auth.hierarchic_bits(nil) if (respect_auth) && (!self.authenticated)
      sumbits
    end

    # Compute the group bits from this permission bitobject
    # Group bits are not hierarchic, i.e. they cannot be topped by other bits
    #
    # @param respect_auth [Permission] the authenticated permissions to filter with. E.g.: Permission::ALL, Permission::REGISTERED
    # @return [Integer] the computed bitmask.
    def group_bits(respect_auth=REGISTERED)
      return self.bit & REGISTERED.bit if (respect_auth) && (!self.authenticated)
      sumbits = 0
      ALL.map{|p| sumbits += p.bit if ((self.bit & p.bit)==p.bit)&&(!p.hierarchic) }
      sumbits
    end

    # Compute the bitmask against an authentication filter permission object
    #
    # @param respect_auth [Permission] the authenticated permissions to filter with. E.g.: Permission::ALL, Permission::REGISTERED
    # @return [Integer] the computed bitmask.
    def all_bits(respect_auth=REGISTERED)
      hierarchic_bits(respect_auth) | group_bits(respect_auth)
    end

    # Check if this permission object fulfils the parameter permission object filtered by an authentication permission object.
    #
    # @param permission [Permission] the permission to check.
    # @param respect_auth [Permission] the authenticated permissions to filter with. E.g.: Permission::ALL, Permission::REGISTERED
    # @return [Boolean] if the permission check has passed.
    def has_permission?(permission, respect_auth=REGISTERED)
      group_bits = permission.group_bits(nil)
      (self.hierarchic_bits(respect_auth) >= permission.hierarchic_bits(nil)) &&
      ((group_bits == 0) || ((self.group_bits(respect_auth) & group_bits) == group_bits))
    end

  end 
end
