module Ricer::Plug::Extender::IsListTrigger

  DEFAULT_OPTIONS = {
    :for => nil,
    per_page: 5,
    pattern: '<search_term>',
    order: 'created_at',
    with_search: true,
  }

  def is_list_trigger(trigger_name, options={})
    
    merge_options(options, DEFAULT_OPTIONS)
    
    class_eval do |klass|

      # Sanity
      if options[:for] != true ### SKIP for runtime choice
        search_class = options[:for]
        throw Exception.new("#{klass.name} is_list_trigger #{options[:class_name]} class is not an ActiveRecord::Base") unless search_class < ActiveRecord::Base
        throw Exception.new("#{klass.name} is_list_trigger has invalid per_page: #{options[:per_page]}") unless options[:per_page].to_i.between?(1, 50)
      end
      
      # Register vars exist in class for reloading code
      Ricer::Plugin.register_class_variable('@list_per_page')
      Ricer::Plugin.register_class_variable('@search_class')
      Ricer::Plugin.register_class_variable('@list_ordering')

      # Set the vars for this plugin
      klass.instance_variable_set('@search_class', options[:for])
      klass.instance_variable_set('@list_per_page', options[:per_page].to_i)
      klass.instance_variable_set('@list_ordering', options[:order])
      
      ##############
      ### Plugin ###
      ##############
      trigger_is trigger_name
      
      has_usage :execute_welcome, ''
      has_usage :execute_list, '<page>'
      
      def execute_welcome
        execute_list(1)
      end
      
      def list_ordering
        self.class.instance_variable_get('@list_ordering')
      end
      
      def execute_list(page)
        show_items(visible_relation(search_class).order(list_ordering), page)
      end

      if options[:with_search]
        has_usage :execute_search, "#{options[:pattern]} <page>"
        has_usage :execute_search, "#{options[:pattern]}"
        
        def execute_search(search_term, page=1)
          relation = search_class
          relation = visible_relation(relation)
          relation = search_relation(relation, search_term)
          return execute_show_single_result(relation, page) if relation.count == 1
          show_items(relation, page)
        end
      end
      
      protected
      
      def list_per_page
        self.class.instance_variable_get('@list_per_page')
      end
      
      def search_class
        self.class.instance_variable_get('@search_class')
      end
      
      def search_relation(relation, arg)
        return relation.search(arg) if relation.respond_to?(:search)
        relation.where(:id => arg)
      end
      
      def visible_relation(relation)
        return relation.visible(user) if relation.respond_to?(:visible)
        relation
      end
     
      def execute_show_single_result(relation, page)
        number = 1
        item = relation.first
        if item.respond_to?(:display_show_item)
          reply item.display_show_item(1)
        else
          reply display_show_item(item, 1)
        end
      end
      
      def display_list_item(item, number)
        "#{number}-#{item.class.name}"
      end

      def display_show_item(item, number)
        "#{number}-#{item.inspect}"
      end
      
      def show_items(relation, page)
        items = relation.page(page.to_i).per(list_per_page)
        out = []
        number = items.offset_value
        items.each do |item|
          number += 1
          if item.respond_to?(:display_list_item)
            out.push(item.display_list_item(number))
          else
            out.push(display_list_item(item, number))
          end
        end
        return rplyr 'plug.extender.is_list_trigger.err_no_list_items', classname: search_class.model_name.human if out.length == 0
        return rplyr 'plug.extender.is_list_trigger.msg_list_item_page', classname: search_class.model_name.human, page:items.current_page, pages:items.total_pages, out:out.join(', ')
      end
      
    end
  end
end
