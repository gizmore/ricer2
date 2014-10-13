module Ricer::Plugins::Board
  class Board < Ricer::Plugin
    
    has_setting name: :interval, type: :duration, scope: :bot, permission: :responsible, min: 2.seconds, max: 1.hour, default: 20.seconds
    
    def upgrade_1
      Model::Board.upgrade_1
    end
    
    ##########################
    ### Announcement timer ###
    ##########################
    def ricer_on_global_startup
      bot.log_debug("Board/Board timer started")
      Ricer::Thread.execute {
        loop {
          sleep get_setting(:interval)
          if plugin_enabled?
            Model::Board.enabled.find_each do |board|
              check_board(board)
            end
          end
        }
      }
    end
    
    def check_board(board)
      bot.log_debug("Board/Board#check_board(#{board.url})")
      begin
        board.fetch_entries!.each do |entry|
          announce_entry(entry)
        end
      rescue StandardError => e
        bot.log_exception(e)
      end
    end
    
    def announce_entry(entry)
      bot.log_debug("Board/Board#announce_entry(#{entry.inspect})")
    end
    
  end
end
