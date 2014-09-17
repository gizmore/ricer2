module Ricer
  class Bot < ActiveRecord::Base
    
    def self.instance; instance_variable_get('@instance'); end
    
    include Ricer::Plug::Extender::KnowsEvents
    
    GLOBAL_MUTEX = Mutex.new
    
    with_global_orm_mapping; def should_cache?; true; end
    
    attr_reader :rand, :botlog
    
    attr_accessor :needs_restart, :running
    
    def running?; @running; end
    def servers; @servers; end
    
    def name; Ricer::Application.config.ricer_name; end
    def randseed; Ricer::Application.config.rice_seeds; end
    def genetic_rice; Ricer::Application.config.genetic_rice; end
    def paddy_queries; Ricer::Application.config.paddy_queries; end
    def chopsticks; Ricer::Application.config.chop_sticks; end
    def version; Ricer::Application.config.ricer_version; end
    def builddate; Ricer::Application.config.ricer_version_date; end
    def owner_name; Ricer::Application.config.ricer_owner; end
    def malware; Ricer::Application.config.ricer_malware rescue []; end
    def embargo; Ricer::Application.config.ricer_embargo rescue []; end

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
    
    def get_plugin(name)
      Ricer::Plugin.by_name(name)
    end
    
    def init
      ActiveRecord::Base.logger = paddy_queries ? Logger.new(STDOUT) : nil
      init_random
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
      Ricer::Irc::User.update_all(:online => false) &&
      Ricer::Irc::Server.update_all(:online => false) &&
      Ricer::Irc::Channel.update_all(:online => false) &&
      Ricer::Irc::Chanperm.update_all(:online => false)
    end
    
    def load_plugins(reload=false)
      map = PluginMap.instance
      map.clear_cache
      I18n.load_path.clear
      @plugins = @loader.load_all
      reload ? reloaded_plugins : init_plugins
      I18n.reload!
      map.validate_plugins!
      map.sort_plugins(@plugins)
      map.sort_plugin_map
      @plugins
    end
    
    def sort_plugins
      PluginMap.sort_plugins(@plugins)
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
          plugin.class.get_init_functions.each{|func| plugin.send(func) }
        rescue Exception => e
          log_exception(e)
        end
      end
      export_translations
    end
    
    def export_translations
      log_info("Generating locale files.")
      Translator::Translator.new(:en).generate(
        Ricer::Locale.all.collect{|locale|locale.iso.to_sym}
      )
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
          plugin.plugin_reload
        rescue Exception => e
          log_exception(e)
        end
      end
    end
    
    def run
      log_info "Starting servers."
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
      log_info "Ricer has quit."
    end
    
    def cleanup_loop
      log_debug "Going into cleanup loop."
      @started_up = false
      while @running
        begin
          if @started_up
            sleep 4
          else
            sleep 1
            @started_up = check_started_up
          end
        rescue SystemExit, Interrupt => e
          servers.each do |server|
            server.send_quit('Caught SystemExit exception.')
          end
          @running = false
        rescue Exception => e
          @running = false
        end
      end
      publish('ricer/on/exit', self)
      sleep 1
    end
    
    # def ricer_on_exit
 # #     publish('ricer/before/exit', self)
      # server = servers.first
      # message = server.fake_message
      # @plugins.each do |plugin|
        # begin
          # plugin.message = message
          # plugin.on_exit
        # rescue => e
          # log_exception(e)
        # end
      # end
    # end
    
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
    
    def puts_mutex
      BotLog::PUTS_MUTEX
    end

    def global_mutex
      GLOBAL_MUTEX
    end
    
  end
end
