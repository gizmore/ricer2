module Ricer::Plugins::Todo
  class Todo < Ricer::Plugin
    
    def upgrade_1
      Ricer::Plugins::Todo::Model::Entry.upgrade_1
    end
    
    def show_random
      get_plugin('Todo/Show').show(Ricer::Plugins::Todo::Model::Entry.random.first)
    end
    
  end
end    
