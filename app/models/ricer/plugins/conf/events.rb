module Ricer::Plugins::Conf
  class Events < Ricer::Plugin
    
    trigger_is :events
    
    protected

    def help_plugins
      events = []
      Ricer::Bot.instance.plugins.each do |plugin|
        events.push(plugin) unless plugin < Ricer::Plugin
      end
      events
    end
 
  end

end
