module Ricer::Plugins::Poll
  class Question < ActiveRecord::Base
    
    MAXLEN = 180
    POLL = 1; MULTI = 2
    RATE = 3; QUESTION = 4
    
    self.table_name = 'poll_questions'

    belongs_to :creator, :class_name => 'Ricer::Irc::User', :foreign_key => 'user_id'

    has_many :options, :class_name => Option.name, :foreign_key => 'question_id'
    has_many :answers, :class_name => Answer.name, :through => :options
    
    validates :text, length:     { minimum:8, maximum:MAXLEN }
    validates :text, similarity: { maximum:0.8 }#, :except => "self.type == #{RATE}"
    
    # Ricer Plugins can install themself. So what?
    def self.upgrade_1
      m = ActiveRecord::Migration.new
      m.create_table table_name do |t|
        t.integer    :user_id,   :null => false
        t.integer    :poll_type, :null => false, :limit => 1
        t.string     :text,      :null => false, :length => MAXLEN
        t.timestamp  :closed_at, :null => true
        t.timestamps
      end
    end

    ## Voted?    
    def has_user_voted?(user)
      answers.where(:user_id => user.id).count > 0
    end
    
    ## Open&Closed
    scope :open, -> { where('closed_at IS NULL') }
    scope :closed, -> { where('closed_at IS NOT NULL') }
    def open?;   self.closed_at.nil?;   end     
    def closed?; self.closed_at != nil; end
    def close!;  self.closed_at = Time.now; self.save!; end
    def can_close?(user, cut_time)
      return true if self.user_id == user.id
      return true if self.created_at.to_i < cut_time
      return false
    end
    
    ## Types
    def type_label; I18n.t("ricer.plugins.poll.type_#{self.poll_type}"); end
    def is_simple_poll?; self.poll_type == POLL; end
    def is_multiple_choice?; self.poll_type == MULTI; end
    def is_numeric_rating?; self.poll_type == RATE; end
    def is_answered_freely?; self.poll_type == QUESTION; end

    ## Search
    search_syntax do
      search_by :text do |scope, phrases|
        scope.where_like([:text] => phrases)
      end
    end
    
    ## ListItem
    def display_list_item(number)
      I18n.t('ricer.plugins.poll.list_item',
        number: number,
        type: type_label,
        question: self.text
      )
    end
    
  end
end
