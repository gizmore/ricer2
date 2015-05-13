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
      klass.register_class_variable(:@db_settings)
      klass.register_class_variable(:@mem_settings)
      klass.register_instance_variable(:@_db_settings)
      klass.register_instance_variable(:@_mem_settings)
      
      @db_settings = klass.instance_variable_define(:@db_settings, {})
      @mem_settings = klass.instance_variable_define(:@mem_settings, [])

      # Static cache for this plugin      
      # @db_settings ||= {}
      # @mem_settings ||= []
      @mem_settings.push(options)
      
      # We have been here already
      return true if @mem_settings.length > 1
      
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
        db_setting_for(name, scope, false).delete!
      end
      
      def increase_setting(name, scope, by=1)
        save_setting(name, scope, get_setting(name, scope) + by)
      end
      
      ######################
      ### Scope Settings ###
      ######################
      def scope_setting(scope, object, name)
        @scope_object = object
        setting = self.setting(name, scope, false)
        @scope_object = nil
        setting        
      end
      
      ##########################
      ### Bot scope settings ###
      ##########################
      def bot_setting(name)
        scope_setting(:bot, bot, name)
      end
      
      def get_bot_setting(name)
        bot_setting(name).to_value
      end
      
      def show_bot_setting(name)
        bot_setting(name).to_label
      end
      
      def save_bot_setting(name, value)
        bot_setting(name).save_value(value)
      end
  
      ##############################
      ### Channel scope settings ###      
      ##############################
      def channel_setting(channel, name)
        scope_setting(:channel, channel, name)
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
        scope_setting(:server, server, name)
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
        scope_setting(:user, user, name)
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
      
      ############################
      ### Objects with setting ###
      ############################
      def objects_with_setting(name, with_value, scope)
        default = memory_setting_for_scope(name, scope)[:default]
        matches = query_objects_with_setting(name, with_value, scope)
        if (default != with_value)
          all = get_all_objects_for_scope(scope)
          matches = all - matches
        end
        matches
      end
      def get_all_objects_for_scope(scope)
        Object.const_get(entity_type_for_scope(scope)).online.all
      end
      def query_objects_with_setting(name, with_value, scope)
        objects = []
        entities = Ricer::Plug::Setting.where(:plugin_id => self.id, :entity_type => entity_type_for_scope(scope), :value => with_value)
        entities.each do |e|
          objects.push e.entity
        end
        objects
      end
      def entity_type_for_scope(scope)
        case scope
        when :bot; "Ricer::Bot";
        when :server; "Ricer::Irc::Server";
        when :channel; "Ricer::Irc::Channel";
        when :user; "Ricer::Irc::User";
        end
      end
      def bots_with_setting(name, with_value)
        objects_with_setting(name, with_value, :bot)
      end
      def channels_with_setting(name, with_value)
        objects_with_setting(name, with_value, :channel)
      end
      def servers_with_setting(name, with_value)
        objects_with_setting(name, with_value, :server)
      end
      def users_with_setting(name, with_value)
        objects_with_setting(name, with_value, :user)
      end
      
      #######################
      ### Cache and magic ###
      #######################
      def db_settings
        @_db_settings ||= self.class.instance_variable_get(:@db_settings)
      end
      
      def memory_settings
        @_mem_settings ||= self.class.instance_variable_get(:@mem_settings)
      end
      
      def memory_setting_for_scope(name, scope)
        memory_settings.each do |options|
          return options if (options[:scope] == scope) && (options[:name] == name)
        end
        throw Exception.new("Unknown setting: #{name} for scope #{scope}.")
        nil
      end
      
      def memory_setting_scopes(name)
        memory_settings.select{ |o| o[:name] == name }.collect{ |o| o[:scope] }
      end
      
      def memory_settings_filter(scopes)
        Array(scopes).select do |scope|
          Ricer::Irc::Scope.matching?(scope, current_message.scopes, channel)
        end
      end
      
      # def db_setting_cache_for(name, scope)
        # db_settings[build_key(name, scope)]
      # end
      
      def db_setting_for(name, scopes=[:user, :channel, :server, :bot], create=true)
        byebug if scopes.nil?
        # cached = db_setting_cache_for(name, Array(scopes).first)
        # return cached if cached && cached.persisted?
        first, cached = nil, nil
        Array(scopes).each{|scope|
          key = build_key(name, scope)
          if cached = db_settings[key]
            return cached if cached.persisted?
          elsif options = memory_setting_for_scope(name, scope)
            cached = Ricer::Plug::Setting.find_or_initialize_by(hash_key(name, scope))
            cached.options = options
            db_settings[key] = cached
            return cached if cached.persisted?
            cached.value = options[:default]
            cached.value = cached.db_value
          end
          first = cached if first.nil?
        }
        first 
      end

      def build_key(name, scope)
       "#{self.id}:#{scope.to_s[0]}:#{default_scope_object_id(scope)}:#{name}"
      end
      
      def hash_key(name, scope)
        { plugin: self,
          entity: default_scope_object(scope),
          name: name, }
      end
      
      # type_id
 #     def setting_scope_id(scope)
 #       Ricer::Plug::Setting.scope_enum(scope)
 #     end
      
      # Get the object_id for a scope / type
      def default_scope_object_id(scope); default_scope_object(scope).id; end
      def default_scope_object(scope)
        return @scope_object if @scope_object
        case scope
        when :bot; bot
        when :channel; channel
        when :server; server
        when :user; user
        else; raise RuntimeError.new("#{self.class.name}.default_scope_object(#{scope}) failed in has_setting.")           
        end
      end
      
    end
  end
end
