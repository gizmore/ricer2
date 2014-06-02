module Ricer::Irc
  class Nickname

    def self.nickname_from_message(message)
      nickname_from_prefix(message.prefix)
    end
    
    def self.nickname_from_prefix(prefix)
      prefix = prefix.ltrim(Ricer::Irc::Permission.all_symbols)
      return prefix if prefix[0] != ':'
      index = prefix.index('!')
      return prefix if index.nil?
      prefix[1..index-1]
    end
    
  end
end