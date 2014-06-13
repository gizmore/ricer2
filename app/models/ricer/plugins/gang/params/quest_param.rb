module Ricer::Plugins::Gang::Params::QuestParam
end
class Ricer::Plug::Params::QuestParam
  def convert_in!(input, options, message)
    Ricer::Plugins::Gang::Game.get_quest(input) || input_failed
  end
  def convert_out!(value, options, message)
    quest.displayname
  end
end
