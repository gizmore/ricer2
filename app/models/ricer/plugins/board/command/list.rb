module Ricer::Plugins::Board
  class List < Ricer::Plugin
    
    is_list_trigger 'list', :for => Ricer::Plugins::Board::Model::Board

    
  end
end
