module Ricer::Plugins::Gang::Params::GenderParam
end
class Ricer::Plug::Params::GenderParam
  def convert_in!(input, options, message)
    Ricer::Plugins::Gang::Game.get_gender(input) || input_failed
  end
  def convert_out!(value, options, message)
    value.to_label
  end
end
