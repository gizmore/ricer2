module Ricer
  class Bot < ActiveRecord::Base
    
    def self.instance; instance_variable_get('@instance'); end
    
    with_global_orm_mapping
    def should_cache?; true; end
    
    attr_reader :rand, :botlog
    attr_accessor :needs_restart, :running, :reboot
    
    def running?; @running; end
    def servers; @servers; end
    
    def name; Ricer::Application.config.ricer_name; end
    def randseed; Ricer::Application.config.rice_seeds; end
    def genetic_rice; Ricer::Application.config.genetic_rice; end
    def chopsticks; Ricer::Application.config.chop_sticks; end
    def version; Ricer::Application.config.ricer_version; end
    def builddate; Ricer::Application.config.ricer_version_date; end
    def owner_name; Ricer::Application.config.ricer_owner; end

    def log_debug(s); @botlog.log_debug(s) if chopsticks; end
    def log_info(s); @botlog.log_info(s); end
    def log_warn(s); @botlog.log_warn(s); end
    def log_error(s); @botlog.log_error(s); end
    def log_exception(e); @botlog.log_exception(e); end
    
    after_initialize :after_init
    def after_init
      self.class.instance_variable_set('@instance', self)
      @loader = PluginLoader.new(self)
      @loader.add_plugin_dir("app/models/ricer/plugins/*")
      @botlog = BotLog.new
      @servers = Ricer::Irc::Server.all
    end
    
    def plugins
      @loader.plugins
    end
    
    def init
      init_random
      @reboot = false
      @running = false
      @needs_restart = false
      load_extenders
      save_all_offline
    end
    
    ### Seed the random generator with seed from config
    ### This ensures we can test nicely
    def init_random
      seed = randseed
      @rand = Random.new(seed)
      log_info "Seeded random generator with #{seed}"
    end
    
    ### Extend Plugin with all extender/
    def load_extenders
      Filewalker.proc_files("app/models/ricer/plug/extender/") do |file|
        load file
        classname = file.rsubstr_from('/').substr_to('.rb').camelize
        Ricer::Plugin.extend Object.const_get("Ricer").const_get('Plug').const_get('Extender').const_get(classname)
        log_info("Loaded plugin extender: #{classname}")
      end
    end
    
    ### XXX: Horrible slow? because online attribute is in the db?
    ### but this way we get ActiveRecord syntax and maybe later
    ### there is a nice fast solution.
    def save_all_offline
      Ricer::Irc::User.update_all(:online => false)
      Ricer::Irc::Server.update_all(:online => false)
      Ricer::Irc::Channel.update_all(:online => false)
      Ricer::Irc::Chanperm.update_all(:online => false)
    end
    
    def load_plugins(reload=false)
      PluginMap.instance.clear_cache
      @plugins = @loader.load_all
      reload ? reloaded_plugins : init_plugins
      I18n.reload!
      sort_plugins
      PluginMap.instance.sort_plugins
    end
    
    def sort_plugins
      @plugins.sort! do |a,b|
        b.trigger_permission.bit - a.trigger_permission.bit rescue 0
      end
      @plugins.sort! do |a,b|
        b.scope.bit - a.scope.bit
      end
      @plugins.sort! do |a,b|
        a.priority - b.priority
      end
#      plugins.each do |p|; puts p.plugin_name; end; byebug
    end
    
    def load_plugin(klass, reload=false)
      plugin = @loader.install_plugin(klass)
      @plugins.push(plugin)
      PluginMap.instance.load_plugin(plugin)
      plugin
    end
    
    def init_plugins
      @plugins.each do |plugin|
        begin
          plugin.on_init
          plugin.class.get_init_functions.each do |func|
            plugin.send(func)
          end
        rescue Exception => e
          log_exception(e)
        end
      end
    end
    
    def plugin_by_id(id)
      @plugins.each do |plugin|
        return plugin if plugin.id == id
      end
      nil
    end
    
    def get_connector(symbol)
      PluginMap.instance.get_connector(symbol)
    end
    
    def connector_symbols
      PluginMap.instance.connector_symbols
    end
    
    def plugins_for_event(event_name)
      PluginMap.instance.plugins_for_event(event_name)
    end
    
    def reloaded_plugins
      @plugins.each do |plugin|
        begin
          plugin.on_reload 
        rescue Exception => e
          log_exception(e)
        end
      end
    end
    
    def run
      log_info "Starting servers..."
      @running = true
      servers.each do |server|
        begin
          server.startup
          sleep 0.5
        rescue => e
          log_exception e
        end
      end
      cleanup_loop
      # Return 1 unless we get killed with .reboot
      Kernel.exit(@reboot)
    end
    
    def cleanup_loop
      @started_up = false
      log_info("Going into cleanup loop.")
      while @running
        begin
          sleep 10
          #Ricer::Thread.cleanup_threads
          @started_up = check_started_up unless @started_up
        rescue SystemExit, Interrupt => e
          ricer_on_exit
          servers.each do |server|
            server.send_quit('Caught SystemExit exception.')
          end
          @running = false
        rescue Exception => e
          ricer_on_exit
          @running = false
        end
      end
      log_info "Ricer shuts down in 1 second."
      sleep(1)
    end
    
    def ricer_on_exit
      server = servers.first
      message = server.fake_message
      @plugins.each do |plugin|
        begin
          plugin.message = message
          plugin.on_exit
        rescue => e
          log_exception(e)
        end
      end
    end
    
    def check_started_up
      servers.each do |server|
        return false unless server.started_up? 
      end
      servers.each do |server|
        server.process_event('ricer_on_startup', server.fake_message)
      end
      server = servers.first
      server.process_event('ricer_on_global_startup', server.fake_message)
      true
    end
    
  end
end
