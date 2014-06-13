module Ricer::Plugins::Gang::Ai::Chatter
  class_eval do |klass|
    def ai_chatter(&code)
      yield code(self)
    end
    def ai_talker(&code)
      yield code(self)
    end
  end

  def chatter(key, *args)
    unless chattered?
      player.message(chatter_text(key, *args))
      chattered
    end
  end
    
  def chatter_text(key, *args)
    begin
      I18n.t!("gang.world.#{key}", *args)
    rescue => e
      "key #{args.inspect}"
    end
  end
    
  def chattered
    if word.nil?
      return [] unless player.instance_variable_defined?(:@gang_chattered)
      return player.instance_variable_get(:@gang_chattered)
    else
      c = chattered
      c.push(word)
      player.instance_variable_set(:@gang_chattered, c)
    end
  end
  
  def chattered?
    player.instance_variable_defined?(:@gang_chattered)
  end
  
  def unchatter
    player.instance_variable_remove(:@gang_chattered)
  end
  
  def chat_word; argline; end

  def chat_is_about?(word, &block)
    if chat_word == word.to_s
      player.add_word(word)
      yield block
    end
  end
end
