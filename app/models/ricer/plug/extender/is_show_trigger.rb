module Ricer::Plug::Extender::IsShowTrigger

  DEFAULT_OPTIONS = {
    :for => nil,
    pattern_id: '<position>',
    pattern: '<search_term>',
  }

  def is_show_trigger(trigger_name, options={})
    
    options = merge_options(options, DEFAULT_OPTIONS)
    
    Ricer::Plugin.register_class_variable('@display_class')

    class_eval do |klass|
      
      throw Exception.new("#{klass.name} is_list_trigger #{options[:class_name]} class is not an ActiveRecord::Base") unless options[:for] < ActiveRecord::Base
      
      klass.instance_variable_set('@display_class', options[:for])
      
      trigger_is trigger_name

      unless options[:pattern_id].nil?
        has_usage :execute_display_id, options[:pattern_id]
        def execute_display_id(number)
          item = visible_relation(display_class).limit(1).from(number-1).first!
#          raise ActiveRecord::RecordNotFound if item.nil?
#          item = visible_relation(display_class).find(id)
          execute_show_item(item, 1)
        end
      end
      
      # unless options[:pattern].nil? && options[:for].respond_to?(:search)
        # has_usage :execute_display_search, options[:pattern]
        # def execute_display_search(search_term)
        # end
      # end
      def execute_show_item(item, number)
        if item.respond_to?(:display_show_item)
          reply item.display_show_item(number)
        else
          reply display_show_item(item, number)
        end
      end
      
      def display_show_item(item, number)
        "#{number}-#{item.inspect}"
      end

      # def execute_display(number)
        # object = visible_relation(display_class).limit(1).from(number-1).first
#         
        # return rplyr 'plug.extender.is_show_trigger.err_not_found', :classname => object.class.human_name if object.nil?
        # reply object.display_show_item
      # end
      
      def visible_relation(relation)
        return relation.visible(user) if relation.respond_to?(:visible)
        relation
      end
      
      # def search_relation(relation, term)
        # return relation.search(term) if relation.respond_to?(:search)
        # relation.where(:id => term)
      # end
      
      def display_class
        self.class.instance_variable_get('@display_class')
      end
      
    end
  end
end
