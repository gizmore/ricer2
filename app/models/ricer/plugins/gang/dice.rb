module Ricer::Plugins::Gang::Dice
  
  def rand(min=0, max=65535)
    bot.rand(min, max)
  end
  
  def either(*args)
    max = 0
    collected = {}
    args.each do |arg|
      if arg.is_a?(Array)
        arg.each do |k|
          collected[k] ||= 0; collected[k] += 100; max += 100
        end
      elsif arg.is_a?(Hash)
        arg.each do |k,v|
          collected[k] ||= 0; collected[k] += v.to_i; max += v.to_i
        end
      else
        collected[arg] ||= 0; collected[arg] += 100; max += 100
      end
    end
    rand = self.rand(0, max-1)
    max = 0
    collected.each do |either,chance|
      max += chance
      return either if rand < chance 
    end
    nil
  end
  
  def dice_percent(percent=100)
    rand(0, 99) < percent
  end
  
end

Ricer::Plugins::Gang::Command.extend Ricer::Plugins::Gang::Dice
Ricer::Plugins::Gang::Item.extend Ricer::Plugins::Gang::Dice
Ricer::Plugins::Gang::Player.extend Ricer::Plugins::Gang::Dice
