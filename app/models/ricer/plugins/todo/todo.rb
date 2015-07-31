module Ricer::Plugins::Todo
  class Todo < Ricer::Plugin
    
    def plugin_revision; 2; end
    
    def upgrade_1
      Ricer::Plugins::Todo::Model::Entry.upgrade_1
    end
    def upgrade_2
      Ricer::Plugins::Todo::Model::Entry.upgrade_2
    end
    
    def show_random
      get_plugin('Todo/Show').show(Ricer::Plugins::Todo::Model::Entry.random.first)
    end
    
  end
end    
