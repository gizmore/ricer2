module Ricer::Base::BaseExtend

  def bot; Ricer::Bot.instance; end
  def lib; Ricer::Irc::Lib.instance; end

end