module Ricer::Plugins::Gang
  class Command < Ricer::Plugin
    
    def self.upgrade_0; end # STUB
    
    # before_execution do |plugin|
      # invoke(player, "gang_before_command", plugin: self)
      # invoke(player, "gang_before_#{plugin.trigger}", plugin: self)
    # end
#       
    # after_execution do |plugin|
      # ActiveSupport::Notifications.instrument "gang.after_command", {plugin: self, c:c}
      # ActiveSupport::Notifications.instrument "gang.after.#{self.plugin_shortname}", {plugin: self, c:c}
    # end
      
  end
end


### Command Extender ###
module Ricer::Plugins::Gang::PluginExtender

  def costs_time(&proc)
    class_eval do |klass|
      
      def busytime
        player.instance_variable_defined?(:@gang_busytime) ? player.instance_variable_get(:@gang_busytime) : 0.0
      end
      
      def busy?
        busytime > Time.now.to_f
      end

      klass.register_exec_function :exec_check_busy
      def exec_check_busy
        raise Ricer::SilentCancel if busy?
      end
      
    end
  end

  # Requires player
  def requires_player(bool=true)
    class_eval do |klass|

      klass.register_exec_function :exec_load_player
      def exec_load_player
        Ricer::Plugins::Gang::Player.player = Ricer::Plugins::Gang::Player.load_user(sender)
        Ricer::Plugins::Gang::Player.message = @message
      end

      klass.instance_variable_set(:@gang_requires_player, bool)
      def requires_player?
        klass.instance_variable_get(:@gang_requires_player, bool)
      end
      
      klass.register_exec_function :exec_requires_player
      def exec_requires_player
        raise Ricer::ExecutionException.new(tp(:err_game_not_started)) if requires_player? && player.nil?
      end
      
      klass.requires_player

    end
  end
  
  
end

Ricer::Plugin.extend Ricer::Plugins::Gang::PluginExtender
