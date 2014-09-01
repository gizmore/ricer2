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
    
    def load_all
      
      @bot.log_debug "PluginLoader.load_all"

      @valid = true
      
      load_i18n_dir('config/locales/rails/')
      load_i18n_dir('config/locales/ricer/')

      @plugins = []
      @plugdirs.each do |path|
        @plugins += load_path(path)
      end
      
      @plugins.each do |plugin|
        plugin.on_load
      end

      @plugins.each do |plugin|
        gather_subcommands(@plugins, plugin)
      end
      
      @plugins
    end
    
    def load_path(path)
      plugins = []

      # Exports first (Cross plugin)     
      @plugdirs.each do |plugdir|
        Dir[plugdir].each do |dir|
          load_export_dir dir
        end
      end
      
      # Then models (Cross plugin)
      @plugdirs.each do |plugdir|
        Dir[plugdir].each do |dir|
          load_model_dir dir
        end
      end
      
      # Then the rest
      @plugdirs.each do |plugdir|
        Dir[plugdir].each do |dir|
          # Langfiles
          load_i18n_dirs(dir)
          # Plugins
          modulename = dir.rsubstr_from('/').camelize
          plugins += load_plugin_dir(dir, modulename)
        end
      end
      
      # Subcommands
      subcommands = []
      plugins.each do |parent_plugin|
        subcommands += load_command_dir(parent_plugin)
      end
      plugins += subcommands

      # \o/
      plugins
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
          rescue => e
            bot.log_exception(e)
          end
          all_loaded += loaded
        end
      end
      all_loaded
    end
    
    def load_export_dir(plugdir)
      load_files(plugdir+'/export/*')
    end
    
    def load_model_dir(plugdir)
      load_files(plugdir+'/model/*')
    end
    
    def load_files(dir_pattern)
      Dir[dir_pattern].each do |path|
        if File.file?(path)
          begin
            @bot.log_info("Loading model or export class #{path}")
            load path
            # install_file(path)
          rescue SystemExit, Interrupt
            raise
          rescue => e
            @valid = false
            @bot.log_error("ERROR IN: #{path}")
            @bot.log_exception(e)
            raise unless @bot.genetic_rice
          end
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
        begin
          classname = path[length..-4].camelize
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
        rescue Exception => e
          @valid = false
          @bot.log_error("ERROR IN: #{path}")
          raise unless @bot.genetic_rice
          @bot.log_exception(e)
        end
      end
      plugins
    end
    
    def install_plugin(classobject)
      
      plugin = classobject.new
      db_plugin = classobject.where(:name => plugin.plugin_name, :bot_id => @bot.id).first
      
      if db_plugin.nil?
        db_plugin = classobject.create!({
          bot_id: @bot.id,
          name: plugin.plugin_name,
        })
      end      
      
      classobject.instance_variable_set('@plugin_id', db_plugin.id)

      plug_version = plugin.plugin_revision
      db_version = db_plugin.revision
      
      errors = false
      
      if db_version < plug_version
        
        @bot.log_info "Installing #{plugin.plugin_name}"
        db_plugin.on_install
        
        begin
          while db_version < plug_version
            dbv = db_version + 1
            if db_plugin.respond_to?("upgrade_#{dbv}")
              ActiveRecord::Base.transaction do              
                db_plugin.send("upgrade_#{dbv}")
              end
            end
            db_version = dbv
          end
        rescue => e
          errors = true
          @valid = false
          @bot.log_exception e
        end

      end

      unless errors
        db_plugin.revision = db_version
        db_plugin.save!
        db_plugin
      else
        nil
      end

    end

  end
end
