module Ricer::Plug::Extender::IsListTrigger
  def is_show_trigger(trigger_name, options={class_name: nil})
    
    Ricer::Plugin.register_class_variable('@display_class')

    class_eval do |klass|
      
      begin
        search_class = Object.const_get(options[:class_name])
        search_object = search_class.new
      rescue Exception => e
        throw Exception.new("#{klass.name} is_list_trigger #{options[:class_name]} is not a class")
      end
      throw Exception.new("#{klass.name} is_list_trigger #{options[:class_name]} class is not an ActiveRecord::Base") unless search_class < ActiveRecord::Base
      throw Exception.new("#{klass.name} is_list_trigger #{options[:class_name]} object does not respond to: display_show_item") unless search_object.respond_to?(:display_show_item)
      
      klass.instance_variable_set('@display_class', Object.const_get(options[:class_name]))
      trigger_is trigger_name
      has_usage :execute_display, '<number>'
      def execute_display(number)
        object = visible_relation(display_class).limit(1).from(number-1).first
        return rplyr 'plug.extender.is_show_trigger.err_not_found', :classname => object.class.human_name if object.nil?
        reply object.display_show_item
      end
      
      protected
      
      def visible_relation(relation)
        relation.visible
      end
      
      def display_class
        self.class.instance_variable_get('@display_class')
      end
      
    end
  end
end