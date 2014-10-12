module Ricer
  class PluginLoader
    
    attr_reader :plugdirs, :valid, :plugins
    
    def bot; @bot; end
    
    def initialize(bot)
      @bot = bot
      @plugdirs, @plugins = [], []
      @valid = true
    end
    
    def add_plugin_dir(path)
      @plugdirs.push(path)
    end
    
    def add_plugin(plugin)
      @plugins.push(plugin)
    end
    
    def load_all
      
      @bot.log_debug "PluginLoader.load_all"

      @valid = true
      
      load_i18n_dir('config/locales/rails/')
      load_i18n_dir('config/locales/ricer/')
      load_i18n_dir('app/models/ricer/plug/')
      
      @plugins = []
      @plugdirs.each do |path|
        load_path(path)
      end
      
      @plugins.each do |plugin|
        plugin.plugin_load
      end

      @plugins.each do |plugin|
        gather_subcommands(@plugins, plugin)
      end
      
      @plugins
    end
    
    def with_plugdirs(&block)
      @plugdirs.each do |plugdir|
        Dir[plugdir].each do |dir|
          yield(dir) unless blacklisted_path?(dir)
        end
      end
    end
    
    def load_path(path)
      plugins = []
      with_plugdirs{|dir|load_i18n_dirs dir} # Langfiles even earlier
      with_plugdirs{|dir|load_export_dir dir} # Exports first (Cross plugin)
      with_plugdirs{|dir|load_model_dir dir} # Then models (Cross plugin)
      with_plugdirs do |dir|
        # Plugins
        modulename = dir.rsubstr_from('/').camelize
        plugins += load_plugin_dir(dir, modulename)
      end
      # Subcommands
      plugins.each do |parent_plugin|
        plugins += load_command_dir(parent_plugin)
      end
      plugins
    end
    
    def blacklisted_path?(path)
      bot.embargo.each{|pattern| return true if path.index(pattern)}
      false
    end

    def gather_subcommands(plugins, plugin)
      if plugin.respond_to?(:has_subcommands?)
        plugin.subcommand_names.each do |cmdname|
          subcommand = gather_subcommand(plugins, plugin, cmdname)
          plugin.add_subcommand(subcommand)
        end
      end
    end
    
    def gather_subcommand(plugins, parent, cmdname)
      plugins.each do |plugin|
        if (parent.plugin_module == plugin.plugin_module) && (plugin.short_class_name.downcase.to_sym == cmdname)
          return plugin
        end
      end
      throw Exception.new("Plugin #{parent.plugin_name} has an unknown subcommand: #{cmdname}")
    end
    
    def load_command_dir(parent_plugin)
      plugdir, all_loaded = parent_plugin.plugin_dir, []
      modulename = parent_plugin.plugin_module
      # For all dirs that are named command...
      Filewalker.traverse_dirs(plugdir) do |_stub_path, dir|
        if dir.end_with?('/command')
          # Load all and subdirs..
          loaded = load_plugin_dir(dir, modulename)
          Filewalker.proc_dirs(dir) do |path, subdir|
            loaded += load_plugin_dir(subdir, modulename)
          end
          # Add the subcommands
          begin
            loaded.each do |loaded_plugin|
              parent_plugin.class.has_subcommand(loaded_plugin.short_class_name.to_s.downcase.to_sym)
            end
          rescue StandardError => e
            bot.log_exception(e)
          end
          all_loaded += loaded
        end
      end
      all_loaded
    end
    
    def load_export_dir(plugdir)
      load_files(plugdir+'/export')
    end
    
    def load_model_dir(plugdir)
      load_files(plugdir+'/model')
    end
    
    def load_files(dir)
      return unless File.directory?(dir)
      Filewalker.traverse_files(dir, '*.rb') do |path|
        begin
          @bot.log_info("Loading model or export class #{path}")
          load path
        rescue StandardError => e
          @valid = false
          @bot.log_error("ERROR IN: #{path}")
          @bot.log_exception(e)
          raise unless @bot.genetic_rice
        end
      end
    end
    
    # Lang files
    def load_i18n_dirs(plugin_dir)
      Filewalker.traverse_dirs(plugin_dir) do |path, dir|
        if dir.end_with?('/lang')
          load_i18n_dir(dir) 
        end
      end
    end
    def load_i18n_dir(plugdir)
      Filewalker.traverse_files(plugdir, '*.yml', true) do |path, dir|
        I18n.load_path.push(path)
      end
    end

    #     
    def load_plugin_dir(plugdir, modulename)
      @bot.log_info "Loading plugin module folder '#{modulename}' from '#{plugdir}'."
      plugins, length = [], plugdir.length + 1;
      Filewalker.proc_files(plugdir, '*.rb') do |path|
        classname = path[length..-4].camelize
        unless blacklisted_plugin?("#{modulename}/#{classname}")
          begin
            @bot.log_info "Loading plugin '#{modulename}::#{classname}'."
            load path
            classobject = Object.const_get("Ricer::Plugins::#{modulename}::#{classname}")
            if classobject < Ricer::Plugin
              plugin = install_plugin(classobject)
              raise Exception.new("Error loading plugin in #{path}") if plugin.nil?
              plugin.plugin_module = modulename
              plugin.plugin_dir = plugdir
              plugin.module_dir = plugdir.substr_to("/#{modulename.underscore}/")||plugdir
              PluginMap.instance.load_plugin(plugin)
              plugins.push(plugin)
            elsif classobject < Ricer::Net::Connection
              PluginMap.instance.load_connector(classobject)
            end
          rescue SystemExit, Interrupt
            raise
          rescue StandardError => e
            @valid = false
            @bot.log_error("ERROR IN: #{path}")
            raise unless @bot.genetic_rice
            @bot.log_exception(e)
          end
        end
      end
      plugins
    end
    
    def blacklisted_plugin?(plugin_name)
      bot.malware.each{|pattern| return true if plugin_name == pattern}
      false
    end
    
    def install_plugin(classobject)
      
      # The singleton for this plugin
      plugin = classobject.new;
      
      db_plugin = classobject.find_or_create_by({bot_id: @bot.id, name: plugin.plugin_name})
      @plugins.push(db_plugin)
            
      db_version = db_plugin.revision
      plug_version = plugin.plugin_revision
      
      errors = false
      
      if db_version < plug_version
        
        @bot.log_info "Installing #{plugin.plugin_name}"
        db_plugin.plugin_install
        db_plugin.call_hook(:plugin_install, db_plugin)
        
        begin
          upgrade_plugin(db_plugin, plug_version)
        rescue StandardError => e
          errors = true
          @valid = false
          @bot.log_exception e
        end

      end

      unless errors
        db_plugin
      else
        @plugins.delete(plugin)
        nil
      end

    end
    
    def upgrade_plugin(plugin, to_version)
      while plugin.revision < to_version
        change_plugin_version(plugin, plugin.revision + 1, :up)
        plugin.revision += 1
        plugin.save!
      end
      true
    end
    
    def downgrade_plugin(plugin, to_version)
      while plugin.revision > to_version
        change_plugin_version(plugin, plugin.revision, :down)
        plugin.revision -= 1
        plugin.save!
      end
    end
    
    def change_plugin_version(plugin, version, direction)
      # if plugin.respond_to?(method)
        if direction == :down
          ActiveRecord::Migration.revert { execute_change_plugin_version(plugin, version) }
        elsif direction == :up
          execute_change_plugin_version(plugin, version)
        end
      # end
    end
    
    def execute_change_plugin_version(plugin, version)
      method = "upgrade_#{version}"
      plugin.call_hook(method)
      plugin.send(method) if plugin.respond_to?(method)
    end

  end
end
