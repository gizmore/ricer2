module Ricer
  class Bot < ActiveRecord::Base
    
    def self.instance; @instance; end

    with_global_orm_mapping
    def should_cache?; true; end
    
    include Ricer::Base::Base
    include Ricer::Base::Events
    
    attr_reader   :rand, :botlog, :servers
    attr_accessor :needs_restart, :running
    
    def running?; @running; end
    def uptime; Time.now - @start_at; end
    
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

    def log_puts(s); @botlog.log_puts(s); end
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
      @_utf8 ||= Ricer::Encoding.find(1)
      @start_at = Time.now
    end
    
    def plugins
      @loader.plugins
    end
    
    def encoding
      @_utf8
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
      bot.log_debug("Bot#save_all_offline")
      Ricer::Irc::User.update_all(:online => false) &&
      Ricer::Irc::Server.update_all(:online => false) &&
      Ricer::Irc::Channel.update_all(:online => false) &&
      Ricer::Irc::Chanperm.update_all(:online => false)
    end
    
    def load_plugins(reload=false)
      bot.log_debug("Bot#load_plugins(#{reload})")
      map = plugin_map
      map.clear_cache
      I18n.load_path.clear
      @plugins = @loader.load_all
      reload ? reloaded_plugins : init_plugins
      I18n.reload!
      map.validate_plugins!
      sort_plugins
      # puts @plugins.collect{|p| "#{p.priority}: #{p.plugin_name}(#{p.subcommand_depth}): #{p.trigger}" }; byebug
      @plugins
    end
    
    def sort_plugins
      plugin_map.sort_plugins(@plugins)
      plugin_map.sort_plugin_map
    end
    
    def load_plugin(klass, reload=false)
      plugin = @loader.install_plugin(klass)
      @plugins.push(plugin)
      plugin_map.load_plugin(plugin)
      plugin
    end
    
    def each_plugins(&block)
      @plugins.each do |plugin|
        begin
          yield(plugin)
        rescue StandardError => e
          log_exception(e)
        end
      end
    end
    
    def init_plugins
      each_plugins do |plugin|
        plugin.plugin_init
        plugin.class.get_init_functions.each{|func| plugin.send(func) }
      end
      loaded_plugins
      export_translations
      @plugins
    end

    def loaded_plugins
      each_plugins{|plugin| plugin.plugin_loaded }
    end
    
    def reloaded_plugins
      each_plugins{|plugin| plugin.plugin_reload }
      loaded_plugins
    end
    
    def export_translations
      log_info("Generating locale files.")
      Translator::Translator.new(:en).generate(
        Ricer::Locale.all.collect{|locale|locale.iso.to_sym}
      )
    end

    def get_connector(symbol)
      plugin_map.get_connector(symbol)
    end
    
    def connector_symbols
      plugin_map.connector_symbols
    end
    
    def plugins_for_event(event_name)
      plugin_map.plugins_for_event(event_name)
    end
    
    def run
      log_info "Starting servers."
      @running = true
      servers.each do |server|
        begin
          server.startup
          sleep 0.5
        rescue StandardError => e
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
          servers.each{|server| server.send_quit('Caught SystemExit exception.') }
          @running = false
        rescue Exception => e
          @running = false
        end
      end
      # Exit event
      servers.each{|server| server.process_event('ricer_on_exit', server.fake_message) }
      servers.first.process_event('ricer_on_global_exit', servers.first.fake_message)
      sleep 1.second
    end
    
    def check_started_up
      # Give all them servers some max time<3 minutes max.
      if uptime.to_i < 90.seconds
        servers.each{|server| return false unless server.started_up? }
      end
      # Startup event.
      servers.each{|server| server.process_event('ricer_on_startup', server.fake_message) }
      servers.first.process_event('ricer_on_global_startup', servers.first.fake_message)
      true
    end

  end
end
