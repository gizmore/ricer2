###
### Provides has_setting extender for plugins.
### Settings can have a scope and a permission who may alter it with "!config".
### Values can be conviniently get, set and shown.
###
### Example:
### has_setting name: :bugs_per_file, type: :integer, scope: :server, permission: :admin, min: -2, max: 100, default: 5 
###
module Ricer::Plug::Extender::HasSetting
  def has_setting(options)
    class_eval do |klass|
      
      # Validate setting definition
      Ricer::Plug::Setting.validate_definition!(klass, options)
      
      # Register static for cleanup
      Ricer::Plugin.register_class_variable('@db_settings')
      Ricer::Plugin.register_class_variable('@mem_settings')

      # Static cache for this plugin      
      @db_settings ||= {}
      @mem_settings ||= []
      @mem_settings.push(options)
      
      ##########################
      ### Autodetected scope ###
      ##########################
      def setting(name, scopes=nil, filter=true)
        scopes ||= memory_setting_scopes(name.to_sym)
        scopes = memory_settings_filter(scopes) if filter
        db_setting_for(name.to_sym, scopes)
      end
      
      def get_setting(name, scopes=nil)
        setting(name, scopes).to_value
      end

      def show_setting(name, scopes=nil)
        setting(name, scopes).to_label
      end
  
      def save_setting(name, scope, value)
        setting(name, scope).save_value(value)
      end
      
      def delete_setting(name, scope)
        setting = db_setting_for(name, scope, false)
        setting.delete!
      end
      
      def increase_setting(name, scope, by=1)
        save_setting(name, scope, get_setting(name, scope) + by)
      end
      
      ##############################
      ### Channel scope settings ###      
      ##############################
      def channel_setting(channel, name)
        @scope_id = channel.id
        back = setting(name, :channel, false)
        @scope_id = nil
        back
      end

      def get_channel_setting(channel, name)
        channel_setting(channel, name).to_value
      end
      
      def show_channel_setting(channel, name)
        channel_setting(channel, name).to_label
      end
      
      def save_channel_setting(channel, name, value)
        channel_setting(channel, name).save_value(value)
      end
      
      #############################
      ### Server scope settings ###
      #############################
      def server_setting(server, name)
        @scope_id = server.id
        back = setting(name, :server, false)
        @scope_id = nil
        back
      end
      
      def get_server_setting(server, name)
        server_setting(server, name).to_value
      end

      def show_server_setting(server, name)
        server_setting(server, name).to_label
      end
      
      def save_server_setting(server, name, value)
        server_setting(server, name).save_value(value)
      end
      
      ###########################
      ### User scope settings ###
      ###########################
      def user_setting(user, name)
        @scope_id = user.id
        back = setting(name, :user, false)
        @scope_id = nil
        back
      end

      def get_user_setting(user, name)
        user_setting(user, name).to_value
      end
      
      def show_user_setting(user, name)
        user_setting(user, name).to_label
      end
      
      def save_user_setting(user, name, value)
        user_setting(user, name).save_value(value)
      end
      
      ##########################
      ### Bot scope settings ###
      ##########################
      def bot_setting(name); setting(name, :bot, false); end
      def get_bot_setting(name); bot_setting(name).to_value; end
      def show_bot_setting(name); bot_setting(name).to_label; end
      def save_bot_setting(name, value); bot_setting(name).save_value(value); end
  
      #######################
      ### Cache and magic ###
      #######################
      def memory_settings
        self.class.instance_variable_get('@mem_settings')
      end
      
      def db_settings
        self.class.instance_variable_get('@db_settings')
      end
      
      def memory_setting_for_scope(name, scope)
        memory_settings.each do |options|
          return options if (options[:scope] == scope) && (options[:name] == name)
        end
        nil
      end
      
      def memory_setting_scopes(name)
        scopes = []
        memory_settings.each do |options|
          if (options[:name] == name)
            scopes.push(options[:scope])
          end
        end
        scopes
      end
      
      def memory_settings_filter(scopes)
        Array(scopes).select do |scope|
          Ricer::Irc::Scope.matching?(scope, @message.scopes, channel)
        end
      end

      def db_setting_for(name, scopes=[:user, :channel, :server, :bot], create=true)
        key = build_key(name, Array(scopes)[0])
        if create
          db_settings[key]||db_setting_for_work(name, scopes, create)
        else
          db_setting_for_work(name, scopes, create)
        end
      end
      
      def db_setting_for_work(name, scopes=[:user, :channel, :server, :bot], create=true)
        first = key = nil
        Array(scopes).each do |scope|
          options = memory_setting_for_scope(name, scope)
          unless options.nil?
            key = build_key(name, scope)
            unless create
              setting = Ricer::Plug::Setting.find(key) rescue nil
              if setting
                setting.options = options
                return db_settings[key] = setting
              end
            else
              setting = Ricer::Plug::Setting.find_or_initialize_by({id: key})
              setting.options = options
              if setting.persisted?
                return db_settings[key] = setting
              elsif first.nil?
                first = setting
                first.value = options[:default]
                first.value = first.db_value
                db_settings[key] = setting
              end
              #db_settings[key] = setting
            end
          end
        end
        first 
      end

      def build_key(name, scope)
        "#{plugin_id}:#{setting_scope_id(scope)}:#{default_scope_id(scope)}:#{name}"
      end
      
      def setting_scope_id(scope)
        Ricer::Plug::Setting.scope_enum(scope)
      end
      
      def default_scope_id(scope)
        return @scope_id unless @scope_id.nil?
        return 0 if scope == :bot
        return server.id if scope == :server
        return sender.id if scope == :user
        return channel.id if channel && (scope == :channel)
        throw Exception.new("#{self.class.name}.default_scope_id(#{scope}) failed in has_setting.")
      end
      
    end
  end
end
