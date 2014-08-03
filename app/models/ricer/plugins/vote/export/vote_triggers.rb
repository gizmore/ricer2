module Ricer::Plug::Extender::VoteTriggers
  
  def is_vote_trigger(options={})
    
    class_eval do |klass|

      throw Exception.new "#{klass.name} options[:for] is not an ActiveRecord" unless options[:for] < ActiveRecord::Base  
      klass.instance_variable_set('@vote_for_class', options[:for])
  
      def vote_class
        self.class.instance_variable_get('@vote_for_class')
      end

      def vote_classname
        vote_class.model_name.human
      end
      
      def votes_all_visible(relation)
        relation
      end

      def votes_visible(relation)
        votes_all_visible(relation).visible(user)
      end
      
      def vote_find(relation, term)
        relation.find(term)
      end
      
      def vote_search(relation, term)
        if term.integer?
          relation.where(:id => term)
        else
          relation.search(term)
        end
      end
      
      protected
      
      # def abbos_item(abbo_item)
        # Ricer::Plugins::Abbo::AbboItem.for(abbo_item)
      # end
      # def abbo_item(arg)
        # relation = abbo_class.all
        # relation = abbos_enabled(relation)
        # relation = abbos_visible(relation)
        # abbo_find(relation, arg)
      # end
      # def abbos_target
        # Ricer::Plugins::Abbo::AbboTarget.for(abbo_target)
      # end
      # def abbo_target
        # @message.reply_target
      # end
    end
    
  end
  
  def is_vote_up_trigger(options={})
    class_eval do |klass|
      
      trigger_is options[:trigger] || :like

      is_vote_trigger options
      
      has_usage :execute, '<id>'
      def execute(id)
        item = vote_class.find(id)
        item.liked_by user
        return reply I18n.t('ricer.plug.extender.vote_triggers.err_vote') unless item.vote_registered?
        return reply I18n.t('ricer.plug.extender.vote_triggers.msg_voted')
      end
      
    end
  end

  def is_vote_down_trigger(options={})
    class_eval do |klass|
      
      trigger_is options[:trigger] || :dislike

      is_vote_trigger options
      
      has_usage :execute, '<id>'
      def execute(id)
        item = vote_class.find(id)
        item.disliked_by user
        return reply I18n.t('ricer.plug.extender.vote_triggers.err_vote') unless item.vote_registered?
        return reply I18n.t('ricer.plug.extender.vote_triggers.msg_voted')
      end
    end
  end
  
  def is_vote_best_trigger(options={})
    class_eval do |klass|
      
    end
  end

end

Ricer::Plugin.extend Ricer::Plug::Extender::VoteTriggers
