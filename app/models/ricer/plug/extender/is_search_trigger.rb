module Ricer::Plug::Extender::IsSearchTrigger

  DEFAULT_SEARCH_TRIGGER_OPTIONS ||= {
    :for => nil,
    per_page: 5,
    order: 'created_at',
    pattern: '<search_term>', # falsy to disable
  }
  
  def is_search_trigger(trigger_name, options={})
    class_eval do |klass|

      merge_options(options, DEFAULT_SEARCH_TRIGGER_OPTIONS)
      
      # Sanity
      if options[:for] != true ### SKIP for runtime choice
        throw "#{klass.name} is_list_trigger #{options[:for]} class is not an ActiveRecord::Base" unless options[:for] < ActiveRecord::Base
        throw "#{klass.name} is_list_trigger has invalid per_page: #{options[:per_page]}" unless options[:per_page].to_i.between?(1, 50)
      end
      unless options[:per_page].to_i.between?(1, 100)
        throw "#{klass.name} is_list_trigger has invalid per_page option: #{options[:per_page]}"
      end
      
      # Register vars exist in class for reloading code
      klass.register_class_variable('@list_per_page')
      klass.register_class_variable('@search_class')

      # Set the vars for this plugin
      klass.instance_variable_set('@search_class', options[:for])
      klass.instance_variable_set('@list_per_page', options[:per_page].to_i)
      
      ##############
      ### Plugin ###
      ##############
      trigger_is trigger_name
      
      klass.has_usage :execute_search, "#{options[:pattern]} <page>"
      klass.has_usage :execute_search, "#{options[:pattern]}"
      klass.has_usage :execute_stats, ""
      def execute_search(search_term, page=1)
        relation = search_relation(visible_relation, search_term)
        relation.count == 1 ?
          execute_show_item(relation) :
          execute_show_items(relation, page)
      end
      
      def execute_stats
        reply I18n.t("ricer.plug.extender.is_search_trigger.stats", count: visible_relation.count, classname: search_class.model_name.human)
      end
      
      def description; I18n.t("ricer.plug.extender.is_search_trigger.description"); end

      
      protected

      def raise_record_not_found
        raise Ricer::ExecutionException.new(tr('plug.extender.is_list_trigger.err_not_found',
          classname: search_class.model_name.human,
        ))
      end
      
      #################
      ### Relations ###
      #################
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
      
      def relation
        search_class
      end
      
      def visible_relation()
        return relation.visible(user) if relation.respond_to?(:visible)
        relation
      end
      
      ###############
      ### Display ###
      ###############
      def display_list_item(item, number)
        "#{number}-#{item.class.name}"
      end

      def display_show_item(item, number)
        "#{number}-#{item.inspect}"
      end
      
      #####################
      ### List Position ###
      #####################
      def calc_item_position(item)
        calc_item_positions([item]).first
      end
      
      def calc_item_positions(items)
        positions = []
        unless items.empty?
          visible_relation.each_with_index do |visible, number|
            if visible.id == items[positions.length].id
              positions.push(number+1)
              break if items[positions.length].nil?
            end
          end
        end
        positions
      end
      
      ####################
      ### Exec helpers ###
      ####################
      def execute_show_item(relation)
        item = relation.first or raise_record_not_found
        number = calc_item_position(item)
        if item.respond_to?(:display_show_item)
          reply item.display_show_item(number)
        else
          reply display_show_item(item, number)
        end
      end

      def execute_show_items(relation, page)
        # Load search result
        items = relation.page(page.to_i).per(list_per_page).all
        # Compute positions
        positions = calc_item_positions(items)
        # Output
        out = []
        items.each do |item|
          if item.respond_to?(:display_list_item)
            out.push(item.display_list_item(positions.shift))
          else
            out.push(display_list_item(item, positions.shift))
          end
        end
        if out.length == 0
          rplyr 'plug.extender.is_list_trigger.err_no_list_items',
            classname: search_class.model_name.human 
        else
          rplyr 'plug.extender.is_list_trigger.msg_list_item_page',
            classname: search_class.model_name.human,
            page:items.current_page,
            pages:items.total_pages,
            out:out.join(', ')
        end
      end
      
    end
  end
end
