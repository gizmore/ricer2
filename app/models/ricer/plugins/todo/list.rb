module Ricer::Plugins::Todo
  class List < Ricer::Plugin

    is_list_trigger "todo list", :for => Model::Entry
    
  end
end
