module Ricer::Plugins::Board
  class Add < Ricer::Plugin
    
    trigger_is :add

    permission_is :owner
    
    denial_of_service_protected
    
    has_usage '<name> <url>'
    def execute(name, url)
      service_thread {
        board = Ricer::Plugins::Board::Model::Board.new({
          url: url,
          name: name,
        })
        board.validate!
        messages = board.test_protocol
        return rply :err_board unless messages
        board.save!
        rply(:msg_added,
          id: board.id,
          name: board.name,
          entry: messages.first.display_entry,
        )
      }
    end
    
  end
end
