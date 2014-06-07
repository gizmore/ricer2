module Ricer
  class PluginLoader
    
    attr_reader :plugdirs, :valid
    
    def initialize(bot)
      @bot = bot
      @plugdirs = []
      @valid = true
    end
    
    def add_plugin_dir(path)
      @plugdirs.push(path)
    end
    
    def load_all
      @bot.log_debug "PluginLoader.load_all"

      @valid = true
      
      load_i18n_dir('config/locales/rails/*')
      load_i18n_dir('config/locales/ricer/*')

      plugins = []
      @plugdirs.each do |path|
        plugins += load_path(path)
      end
      
      plugins.each do |plugin|
        gather_subcommands(plugins, plugin)
      end
      
      plugins.sort! do |a,b|
        b.trigger_permission.bit - a.trigger_permission.bit rescue 0
      end
      plugins.sort! do |a,b|
        b.scope.bit - a.scope.bit
      end
      plugins.sort! do |a,b|
        a.priority - b.priority
      end

#      plugins.each do |p|; puts p.plugin_name; end; byebug
      
      I18n.reload!

      plugins
    end
    
    def load_path(path)
      plugins = []

      # Exports first      
      @plugdirs.each do |plugdir|
        Dir[plugdir].each do |dir|
          load_export_dir dir
        end
      end
      
      # Then models
      @plugdirs.each do |plugdir|
        Dir[plugdir].each do |dir|
          load_model_dir dir
        end
      end
      
      # Then the rest
      @plugdirs.each do |plugdir|
        Dir[plugdir].each do |dir|
          plugins += load_plugin_dir dir
        end
      end
      
      plugins
    end
    
    def gather_subcommands(plugins, plugin)
      return unless plugin.respond_to?(:has_subcommands?)
      plugin.subcommand_names.each do |cmdname|
        subcommand = gather_subcommand(plugins, plugin, cmdname)
        plugin.add_subcommand(subcommand)
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
    
    def load_export_dir(plugdir)
      load_files(plugdir+'/export/*')
    end
    def load_model_dir(plugdir)
      load_files(plugdir+'/model/*')
    end
    def load_files(dir_pattern)
      begin
        Dir[dir_pattern].each do |path|
          if File.file?(path)
            begin
              @bot.log_info("Loading model or export class #{path}")
              load path
              # install_file(path)
            rescue => e
              @bot.log_error("Error in #{path}")
              @bot.log_exception(e)
              @valid = false
            end
          end
        end
      rescue => e
        @valid = false
        @bot.log_error("Error in #{plugdir}")
        @bot.log_exception(e)
      end
    end
    
    # def install_file(path)
      # parts = path.split('/')
      # Object.const_get('Ricer').const_get('Plugins').const_get(modulename).const_get(classname)
    # end
    
    def load_i18n_dir(plugdir)
      Dir[plugdir].each do |path|
        I18n.load_path.push(path)
      end
    end
    
    def load_plugin_dir(plugdir)
      plugins = []
 
      length = plugdir.length + 1;
      modulename = plugdir[(plugdir.rindex('/')+1)..-1].camelize
      @bot.log_info "Loading plugin module folder '#{modulename}' from '#{plugdir}'."
      
      Dir[plugdir+'/*'].each do |path|
        if File.file?(path)
          begin
            classname = path[length..-4].camelize
            @bot.log_info "Loading plugin '#{modulename}::#{classname}'."
            load path
            classobject = Object.const_get('Ricer').const_get('Plugins').const_get(modulename).const_get(classname)
            if classobject < Ricer::Plugin
              plugin = install_plugin(classobject)
              PluginMap.instance.load_plugin(plugin)
              plugins.push(plugin)
            elsif classobject < Ricer::Net::Connection
              PluginMap.instance.load_connector(classobject)
            end
          rescue Exception => e
            @bot.log_error("Error in #{path}")
            @bot.log_exception(e)
            @valid = false
          end
        end
      end
      load_i18n_dir(plugdir+'/lang/*')
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
              db_plugin.send("upgrade_#{dbv}")
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
      end
      
      db_plugin
    end

  end
end
