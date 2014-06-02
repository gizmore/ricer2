module Ricer::Plugins::Abbo::Abbonementable

  def abbonementable_by(abbo_classes)
    class_eval do |klass|
      
      # belongs_to :abbo_item, :through => :abbonements, :polymorphic => true
#      has_many :abbo_targets, :class_name => 'Ricer::Plugins::Abbo::AbboTarget'
      # has_many :abbo_targets, :through => :abbonements, :polymorphic => true

        # has_many :articles, :through => :tags, :source => :taggable, :source_type => 'Article'
      
      @abbo_classes = abbo_classes
      def abbo_classes; self.class.abbo_classes; end;
      def self.abbo_classes; @abbo_classes; end;
      
      # scope :abbonemented_by, ->(target) {
        # joins(:abbo_targets).
# #joins(:abbo_item).where({abbo_target: target}).
        # where('abbonements.target_id=? AND abbonements.target_type=?', target.id, target.class).
        # where("abbonements.item_id = #{table_name}.id AND abbonements.item_type=?", name)
        # # joins(:abbo_targets).where()
        # # where(abbo_targets.include?(target)) 
# #        where('SELECT 1 FROM abbo_targets WHERE abbo_target_id=? AND abbo_target_type=? AND abbo_item_id=? and abbo_item_type=?', target.id, target.class.name, self.id, self.class.name)
        # # where('SELECT 1 FROM abbo_targets WHERE target_id=? AND target_type=? iAND ', target.id, target.class.name)
      # }
      
      # scope :abbonemented_by(target)
      # def self.abbonemented_by(target)
        # w
        # Ricer::Plugins::Abbo::Abbonement.where(abbo_target: abbo_target(target)).each.collect do |abbo|
          # abbo.abbo_item
        # end
      # end
      
      def can_abbonement?(abbonement)
        abbo_classes.include?(abbonement.class)
      end
      
      def abbonemented?(abbonement)
        abbo(abbonement) != nil
      end
      
      def abbonement!(abbonement)
        return false unless can_abbonement?(abbonement)
        return true if abbonemented?(abbonement)
        Ricer::Plugins::Abbo::Abbonement.create!({abbo_target:abbo_target(abbonement), abbo_item:abbo_item})
        return true
      end
      
      def unabbonement!(abbonement)
        return true unless abbonemented?(abbonement)
        abbo_relation(abbonement).delete_all
      end
      
      def abbonements
        Ricer::Plugins::Abbo::Abbonement.where(abbo_item:abbo_item)
      end
  
      private
      def abbo_item
        Ricer::Plugins::Abbo::AbboItem.for(self)
      end
      def abbo_target(abbonement)
        self.class.abbo_target(abbonement)
      end
      def self.abbo_target(abbonement)
        Ricer::Plugins::Abbo::AbboTarget.for(abbonement)
      end
      
      def abbo_relation(abbonement)
        Ricer::Plugins::Abbo::Abbonement.where({abbo_target:abbo_target(abbonement), abbo_item:abbo_item})        
      end
      
      def abbo(abbonement)
        abbo_relation(abbonement).first
      end
      
    end
  end

end

ActiveRecord::Base.extend Ricer::Plugins::Abbo::Abbonementable
