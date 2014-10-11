module Ricer::Plugins::Board
  class Board < Ricer::Plugin
    
    def upgrade_1
      Model::Board.upgrade_1
    end
    
    def ricer_on_global_startup
      
    end
    
  end
end
