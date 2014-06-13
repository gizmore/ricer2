module Ricer::Plugins::Gang::Params::RaceParam
end
class Ricer::Plug::Params::RaceParam
  def convert_in!(input, options, message)
    Ricer::Plugins::Gang::Game.get_race(input) || input_failed
  end
end
