module Ricer::Plugins::Fun
  class Decide < Ricer::Plugin
    
    trigger_is :decide
    
    # Static var that is reset on reload
    def plugin_init
      @outcomes = []
    end
    
    def old_outcome(key)
      @outcomes.each do |outcome|
        return outcome[:outcome] if outcome[:key] == key
      end
      nil
    end
    
    def outcome_key(sorted_choices)
      sorted_choices.join("")
    end
    
    has_usage 
    def execute
      rply yes_or_no
    end
    
    def yes_or_no
      bot.rand.rand(0..1) == 1 ? :yes : :no      
    end
    
    has_usage :execute_with_input, '<..string..>'
    def execute_with_input(text)
      split_pattern = Regexp.new("\\s+#{t(:or)}\\s+")
      choices = text.rtrim('?').split(split_pattern)
      return execute if choices.length == 1
      choices.sort!
      key = outcome_key(choices)
      answer = old_outcome(key)
      return reply answer unless answer.nil?
      if choices.length == 1
        outcome = yes_or_no
      else
        outcome = bot.rand.rand(0..(choices.length-1))
        outcome = choices[outcome]
      end
      @outcomes.unshift({key:key, outcome:outcome})
      @outcomes.slice!(0, 10) if @outcomes.length > 10
      reply outcome
    end
    
  end
end
