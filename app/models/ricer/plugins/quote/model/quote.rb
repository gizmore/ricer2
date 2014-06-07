module Ricer::Plugins::Quote::Model
  class Quote < ActiveRecord::Base
    
    belongs_to :user, :class_name => 'Ricer::Irc::User'
    belongs_to :channel, :class_name => 'Ricer::Irc::Channel'
    delegate :server, to: :user
    
    validates_length_of :message, :minimum => 1, :maximum => 400, :allow_blank => false
    
    def self.upgrade_1
      m = ActiveRecord::Migration
      m.create_table table_name do |t|
        t.integer   :user_id,    :null => false
        t.integer   :channel_id, :null => true
        t.text      :message,    :null => false, :length => 400
        t.timestamp :created_at
      end
    end

    ##################
    ### Searchable ###
    ##################    
    search_syntax do
      search_by :text do |scope, phrases|
        columns = [:message]
        scope.where_like(columns => phrases)
      end
      search_by :by do |scope, phrases|
        columns = ['users.nickname']
        scope.joins(:user).where_like(columns => phrases)
      end
      search_by :before do |scope, phrases|
        columns = ['quotes.updated_at']
        scope.where('quotes.updated at <= ?', phrases)
      end
      search_by :after do |scope, phrases|
        columns = ['quotes.updated_at']
        scope.where('quotes.updated at >= ?', phrases)
      end
      
    end
    
    ################
    ### ListItem ###
    ################
    scope :visible, ->(user) { all }
    def display_show_item(number)
      I18n.t('ricer.plugins.quote.display_show_item', id: self.id, message: self.message)
    end
    def display_list_item(number)
      I18n.t('ricer.plugins.quote.display_list_item', id: self.id)
    end
    
  end
end
