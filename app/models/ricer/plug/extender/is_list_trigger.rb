module Ricer::Plug::Extender::IsListTrigger
  def is_list_trigger(trigger_name, options={per_page: nil, class_name: nil})
    
    options[:per_page] = 10 if options[:per_page].nil?

    Ricer::Plugin.register_class_variable('@search_class_name')
    Ricer::Plugin.register_class_variable('@list_per_page')
    
    class_eval do |klass|
      begin
        search_class = options[:for] || Object.const_get( options[:class_name])
        options[:class_name] = search_class.name
        search_object = search_class.new({})
      rescue Exception => e
        throw Exception.new("#{klass.name} is_list_trigger #{options[:class_name]} is not a class: #{e.to_s}")
      end
      throw Exception.new("#{klass.name} is_list_trigger #{options[:class_name]} class is not an ActiveRecord::Base") unless search_class < ActiveRecord::Base
      
      throw Exception.new("#{klass.name} is_list_trigger has invalid per_page: #{options[:per_page]}") unless options[:per_page].to_i.between?(1, 50)
      throw Exception.new("#{klass.name} is_list_trigger #{options[:class_name]} object does not respond to: display_show_item") unless search_object.respond_to?(:display_show_item)
      throw Exception.new("#{klass.name} is_list_trigger #{options[:class_name]} object does not respond to: display_list_item") unless search_object.respond_to?(:display_list_item)
      throw Exception.new("#{klass.name} is_list_trigger #{options[:class_name]} class does not respond to: search") unless search_class.respond_to?(:search)
      throw Exception.new("#{klass.name} is_list_trigger #{options[:class_name]} class does not respond to: visible") unless search_class.respond_to?(:visible)
      
      klass.instance_variable_set('@search_class_name', options[:class_name])
      klass.instance_variable_set('@list_per_page', options[:per_page].to_i)

      trigger_is trigger_name
      
      has_usage :execute_welcome, ''
      has_usage :execute_list, '<page>'
      has_usage :execute_search, '<search_term> [<page>]'
      
      def search_class_name
        self.class.instance_variable_get('@search_class_name')
      end
      
      def search_class
        Object.const_get(search_class_name)
      end

      def execute_search(search_term, page=1)
        relation = search_class.all
        relation = visible_relation(relation)
        relation = search_relation(relation, search_term)
        return reply relation.first.display_show_item(1) if relation.count == 1
        show_items(relation, page)
      end
      
      def execute_list(page=1)
        show_items(visible_relation(search_class.all).order("created_at"), page)
      end
      
      def execute_welcome
        execute_list
      end
      
      protected
      
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
