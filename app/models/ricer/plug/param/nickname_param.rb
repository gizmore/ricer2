module Ricer::Plug::Param
  class NicknameParam < Base
    def self.get_arg(server, arg, message)
      lib.nickname_valid?(arg) ? arg : nil? 
    end
  end
end
