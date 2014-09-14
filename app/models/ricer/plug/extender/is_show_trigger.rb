module Ricer::Plug::Extender::IsShowTrigger
  def is_show_trigger(trigger_name, options={})
    class_eval do |klass|
      
      # Consume this away for "is_list_trigger"
      position_pattern = options.delete(:position_pattern) || '<position>'

      # No pagination without search for "is_ist_trigger"
      options[:pagination_pattern] = nil
      
      # We offer positional display
      if position_pattern
        klass.has_usage :execute_show_position, position_pattern
        def execute_show_position(position)
          execute_show_item(all_visible_relation.limit(1).offset(position-1))
        end
      end

      # But the rest is quite the same as "is_list_trigger"
      klass.is_list_trigger(trigger_name, options)

    end
  end
end
