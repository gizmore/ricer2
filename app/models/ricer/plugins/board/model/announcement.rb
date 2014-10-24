module Ricer::Plugins::Board
  class Model::Announcement
    
    include Ricer::Base::Base
    include Ricer::Base::Translates
    
    attr_reader :thread, :date, :board, :url, :user, :title
    
    def initialize(parts)
      @thread, @date, @board, @url, @user, @title = *parts
    end
    
    def display_entry
      tt("ricer.plugins.board.entry", {
        user: lib.no_highlight(@user),
        date: l(@date),
        title: @title,
        url: @url,
      })
    end
        
  end
end
