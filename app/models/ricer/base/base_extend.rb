module Ricer::Base::BaseExtend

  def bot; Ricer::Bot.instance; end
  def lib; Ricer::Irc::Lib.instance; end
  def current_message; Thread.current[:ricer_message]; end

end