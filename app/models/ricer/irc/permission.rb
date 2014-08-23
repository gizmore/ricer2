module Ricer::Irc
  class Permission
    
    attr_reader :priv, :symbol, :char, :bit, :name, :modeable, :hierarchic, :authenticated
    
    def initialize(hash); hash.each { |name, value| instance_variable_set("@#{name}", value) }; end

    def modeable?; @modeable; end
    def hierarchical?; @hierarchic; end
    def authenticated=(bool); @authenticated = bool; end 

    PUBLIC =        new(priv:'p', symbol:'',  char:'',  bit:0x0000,  :name => :public,        :modeable => false, :hierarchic => true,  :authenticated => true)
    REGISTERED =    new(priv:'r', symbol:'',  char:'',  bit:0x0001,  :name => :registered,    :modeable => false, :hierarchic => true,  :authenticated => true)
    AUTHENTICATED = new(priv:'l', symbol:'',  char:'',  bit:0x0002,  :name => :authenticated, :modeable => false, :hierarchic => true,  :authenticated => true)
    VOICE =         new(priv:'v', symbol:'+', char:'v', bit:0x0004,  :name => :voice,         :modeable => true,  :hierarchic => true,  :authenticated => true)
    HALFOP =        new(priv:'h', symbol:'%', char:'h', bit:0x0008,  :name => :halfop,        :modeable => true,  :hierarchic => true,  :authenticated => true)
    OPERATOR =      new(priv:'o', symbol:'@', char:'o', bit:0x0010,  :name => :operator,      :modeable => true,  :hierarchic => true,  :authenticated => true)
    MODERATOR =     new(priv:'m', symbol:'',  char:'',  bit:0x0020,  :name => :moderator,     :modeable => true,  :hierarchic => false, :authenticated => true)
    STAFF =         new(priv:'s', symbol:'',  char:'',  bit:0x0040,  :name => :staff,         :modeable => true,  :hierarchic => false, :authenticated => true)
    ADMIN =         new(priv:'a', symbol:'',  char:'',  bit:0x0080,  :name => :admin,         :modeable => true,  :hierarchic => false, :authenticated => true)
    FOUNDER =       new(priv:'f', symbol:'~', char:'~', bit:0x0100,  :name => :founder,       :modeable => true,  :hierarchic => true,  :authenticated => true)
    IRCOP =         new(priv:'i', symbol:'!', char:'!', bit:0x0200,  :name => :ircop,         :modeable => true,  :hierarchic => true,  :authenticated => true)
    OWNER  =        new(priv:'x', symbol:'',  char:'',  bit:0x0400,  :name => :owner,         :modeable => true,  :hierarchic => false, :authenticated => true)
    RESPONSIBLE =   new(priv:'y', symbol:'',  char:'',  bit:0x0800,  :name => :responsible,   :modeable => false, :hierarchic => false, :authenticated => true)
    ALL = [ PUBLIC, REGISTERED, AUTHENTICATED, VOICE, HALFOP, OPERATOR, MODERATOR, STAFF, ADMIN, FOUNDER, IRCOP, OWNER, RESPONSIBLE ]
    
    def self.all_symbols
      back = ''
      ALL.each do |p|;  back += p.symbol; end
      back
    end
      
    def to_s
      super + " Ricer::Irc::Priviledge(#{self.priv})"
    end
    
    def to_label
      I18n.t("ricer.irc.permission.#{self.name}")
    end
    
    def display
      out = 'p'
      bits = self.all_bits(true)
      bold = "\x02"
      ALL.each do |p|
        if (p.bit & bits) > 0
          out += "#{bold}#{p.priv}#{bold}"
        elsif (p.bit & self.bit) > 0
          out += "#{p.priv}"
        end
      end
      out
    end
    
    def self.valid?(name)
      self.by_name(name) != nil
    end
    
    def self.by_char(char)
      char = char.to_s.downcase
      ALL.each do |p|
        return p if p.priv == char
      end
      nil
    end
    
    def self.by_name(name)
      name = name.to_s.downcase.to_sym
      ALL.each do |p|
        return p if p.name == name
      end
      nil
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
      negate = false
      if arg[0] == '-'
        negate = true
      end
      arg = arg.to_s.ltrim('+-')
      permission = self.by_name(arg) || self.by_label(arg)
      return nil if permission.nil?
      return permission.negated if negate
      return permission
    end
    
    def negated
      gotit = nil
      ALL.each do |p|
        gotit = p if p.bit == self.bit
        return p if gotit
      end
      nil
    end
    
    def self.by_permission(permissions, authenticated=false)
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
      new({priv: priv, symbol: symbol, char: char, bit:bit, name: name, modeable: false, hierarchical: false, authenticated: authenticated})
    end
    
    def merge(permission)
      self.class.by_permission(permission.bits | self.bits, self.authenticated)
    end
    
    def substract(permission)
      self.class.by_permission(permission.bits & self.bits, self.authenticated)
    end

    # def -(permission)
      # self.by_permission(permission.bit & self.bit)
    # end
    
    def bits
      sumbits = 0
      ALL.map do |p|
        sumbits |= p.bit if self.bit >= p.bit
      end
      sumbits
    end
    
    def hierarchic_bits(respect_auth=REGISTERED)
      sumbits = 0
      ALL.map do |p|; sumbits += p.bit if (self.bit >= p.bit) && p.hierarchic; end
      sumbits &= respect_auth.hierarchic_bits(nil) if respect_auth && (!self.authenticated)
      sumbits
    end
    def group_bits(respect_auth=REGISTERED)
      return 0 if respect_auth && (!self.authenticated)
      sumbits = 0
      ALL.map do |p|; sumbits += p.bit if (self.bit >= p.bit) && (!p.hierarchic); end
      sumbits
    end
    def all_bits(respect_auth=false)
      hierarchic_bits(respect_auth) | group_bits(respect_auth)
    end
    
    def has_permission?(permission, respect_auth=REGISTERED)
      permission = PUBLIC if permission.nil?
      hierarchic_passed = self.hierarchic_bits(respect_auth) >= permission.hierarchic_bits
      group_bits_passed = (permission.group_bits == 0) || ((self.group_bits(respect_auth) & permission.group_bits) == permission.group_bits)
      hierarchic_passed && group_bits_passed
    end

  end 
end
