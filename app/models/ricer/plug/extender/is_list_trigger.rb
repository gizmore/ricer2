module Ricer::Plug::Extender::IsListTrigger

  DEFAULT_OPTIONS = {
    per_page: 5
  }

  def is_list_trigger(trigger_name, options={per_page: 5, :for => nil})
    
    # Options
    options = merge_options(options, DEFAULT_OPTIONS)
#    options[:per_page] = options[:per_page].to_i rescue 5
#    has_setting name: :per_page, type: :integer, min: 1, max: 50, scope: :bot, default: options[:per_page]||5
    
    class_eval do |klass|

      # Sanity
      search_class = options[:for]
      throw Exception.new("#{klass.name} is_list_trigger #{options[:class_name]} class is not an ActiveRecord::Base") unless search_class < ActiveRecord::Base
      throw Exception.new("#{klass.name} is_list_trigger has invalid per_page: #{options[:per_page]}") unless options[:per_page].to_i.between?(1, 50)
      throw Exception.new("#{klass.name} is_list_trigger #{options[:class_name]} object does not respond to: display_show_item") unless search_class.instance_methods.include?(:display_show_item)
      throw Exception.new("#{klass.name} is_list_trigger #{options[:class_name]} object does not respond to: display_list_item") unless search_class.instance_methods.include?(:display_list_item)
      throw Exception.new("#{klass.name} is_list_trigger #{options[:class_name]} class does not respond to: search") unless search_class.respond_to?(:search)
      throw Exception.new("#{klass.name} is_list_trigger #{options[:class_name]} class does not respond to: visible") unless search_class.respond_to?(:visible)
      
      # Register vars exist in class for reloading code
      Ricer::Plugin.register_class_variable('@list_per_page')
      Ricer::Plugin.register_class_variable('@search_class')

      # Set the vars for this plugin
      klass.instance_variable_set('@list_per_page', options[:per_page].to_i)
      klass.instance_variable_set('@search_class', options[:for])
      def search_class; self.class.instance_variable_get('@search_class'); end
      
      ##############
      ### Plugin ###
      ##############
      trigger_is trigger_name
      
      has_usage :execute_welcome, ''
      has_usage :execute_list, '<page>'
      has_usage :execute_search, '<search_term> [<page>]'
      
      def execute_welcome
        execute_list(1)
      end
      
      def execute_list(page)
        show_items(visible_relation(search_class.all).order("created_at"), page)
      end

      def execute_search(search_term, page=1)
        relation = search_class.all
        relation = visible_relation(relation)
        relation = search_relation(relation, search_term)
        return reply relation.first.display_show_item(1) if relation.count == 1
        show_items(relation, page)
      end
      
      ###       
      protected
       ###
      
      def list_per_page
        self.class.instance_variable_get('@list_per_page')
      end
      
      def show_items(relation, page)
        items = relation.page(page.to_i).per(list_per_page)
        out = []
        number = items.offset_value
        items.each do |item|
          number += 1
          out.push(item.display_list_item(number))
        end
        return rplyr 'plug.extender.is_list_trigger.err_no_list_items', classname: search_class.model_name.human if out.length == 0
        rplyr 'plug.extender.is_list_trigger.msg_list_item_page', classname: search_class.model_name.human, page:items.current_page, pages:items.total_pages, out:out.join(', ')
      end
      
      def visible_relation(relation)
        return relation.visible(user) if relation.respond_to?(:visible)
        relation
      end
  
      def search_relation(relation, arg)
        relation.search(arg)
      end
      
    end

  end
end
