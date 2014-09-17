module Ricer::Plug::Extender::AbboTriggers
  
  def is_abbo_trigger(options={})
    
    class_eval do |klass|
  
      klass.register_class_variable('@abbo_for_class')
      klass.instance_variable_set('@abbo_for_class', options[:for])
  
      def abbo_class; self.class.instance_variable_get('@abbo_for_class'); end
      def abbo_search(relation, term)
        if term.integer?
          relation.where(:id => term)
        else
          relation.search(term)
        end
      end
      def abbos_enabled(relation)
        relation
      end
      def abbos_visible(relation)
        relation
      end
      def abbo_find(relation, term)
        relation.find(term)
      end
      protected
      def abbo_classname
        abbo_class.model_name.human
      end
      def abbos_item(abbo_item)
        Ricer::Plugins::Abbo::AbboItem.for(abbo_item)
      end
      def abbo_item(arg)
        relation = abbo_class.all
        relation = abbos_enabled(relation)
        relation = abbos_visible(relation)
        abbo_find(relation, arg)
      end
      def abbos_target
        Ricer::Plugins::Abbo::AbboTarget.for(abbo_target)
      end
      def abbo_target
        current_message.reply_target
      end
    end
    
  end
  
  def is_add_abbo_trigger(options={})
    class_eval do |klass|
      is_abbo_trigger(options)
      trigger_is :abbo
#      def description; I18n.t('ricer.plugins.abbos.add_abbo.description'); end
      has_usage :execute, '<id>'
      has_usage :execute, '<search_term>'
      def execute(arg)
        abbo_item = self.abbo_item(arg)
        return rplyr 'plugins.abbos.err_abbo_item', classname:abbo_classname if abbo_item.nil?
        return rplyr 'plugins.abbos.err_invalid_target', classname:abbo_classname unless abbo_item.can_abbonement?(abbo_target)
        return rplyr 'plugins.abbos.err_abbo_twice', classname:abbo_classname if abbo_item.abbonemented?(abbo_target)
        Ricer::Plugins::Abbo::Abbonement.create({abbo_target:abbos_target, abbo_item:abbos_item(abbo_item)})
        return rplyr 'plugins.abbos.msg_abbonemented', classname:abbo_classname
      end
    end
  end

  def is_remove_abbo_trigger(options={})
    class_eval do |klass|
      is_abbo_trigger(options)
      trigger_is :unabbo
#      def description; I18n.t('ricer.plugins.abbos.remove_abbo.description'); end
      has_usage :execute, '<id>'
      has_usage :execute, '<search_term>'
      def execute(arg)
        abbo_item = self.abbo_item(arg)
        return rplyr 'plugins.abbos.err_abbo_item', classname:abbo_classname if abbo_item.nil?
        return rplyr 'plugins.abbos.err_invalid_target', classname:abbo_classname unless abbo_item.can_abbonement?(abbo_target)
        return rplyr 'plugins.abbos.err_not_abboed' unless abbo_item.abbonemented?(abbo_target)
        Ricer::Plugins::Abbo::Abbonement.where({abbo_target:abbos_target, abbo_item:abbos_item(abbo_item)}).delete_all
        return rplyr 'plugins.abbos.msg_unabbonemented', classname:abbo_classname
      end
    end
  end

  def is_abbo_list_trigger(options={})
    class_eval do |klass|
      is_abbo_trigger(options)
      is_list_trigger options[:trigger]||:abbos, options
      def visible_relation(relation)
        return Ricer::Plugins::Abbo::Abbonement.for_target(abbo_target)
        #(:abbo_target => ) #relation.abbonemented_by(current_message.reply_target)
      end
    end
  end

end

Ricer::Plugin.extend Ricer::Plug::Extender::AbboTriggers
