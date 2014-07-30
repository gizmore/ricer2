module Ricer::Plugins::Abbo::Abbonementable
  def abbonementable_by(abbo_classes)
    class_eval do |klass|

      @abbo_classes = abbo_classes
      def abbo_classes; self.class.abbo_classes; end;
      def self.abbo_classes; @abbo_classes; end;
      
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
