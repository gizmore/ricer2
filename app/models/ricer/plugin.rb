module Ricer

  class SilentCancel < Exception; end
  class NotImplemented < StandardError; end
  class ExecutionException < StandardError; end
  class ParamException < ExecutionException; end
  class WorkerException < ExecutionException; end
  
  class Plugin < ActiveRecord::Base
    
    include Ricer::Base::Base
    include Ricer::Base::Hook
    include Ricer::Base::Translates
    
    DEFAULT_PRIORITY = 50
    
    attr_accessor :plugin_module, :plugin_dir, :module_dir
    
    # Current message for current thread
    # def message
      # bot.log_exception(StandardError.new("DEPRECATED accessor plugin#message!!!"))
      # current_message
    # end
    
    def servers; bot.servers; end

    def user; current_message.sender; end
    def sender; current_message.sender; end
    def server; current_message.server; end
    def channel; current_message.channel; end
    def args; current_message.args; end
    def line; args[1]; end
    def privmsg_line; current_message.privmsg_line; end
    def argline
#      return @_argline unless @argline.nil?
      back = line
      subcommand_depth.times do
        back = back.substr_from(' ').ltrim(' ') rescue ''
      end
      back
#      @_argline = back
      ## .ping a , d1, s1 
      # return nil if line.count(' ') < subcommand_depth
      # return line.split(/ +/, subcommand_depth+1)[-1]
    end
    
    def core_plugin?; false; end
    def priority; self.class.instance_variable_defined?('@priority') ? self.class.instance_variable_get('@priority') : DEFAULT_PRIORITY; end
    def scope; Ricer::Irc::Scope::EVERYWHERE; end
    
    # def self.plugin_id; instance_variable_get('@plugin_id'); end
    # def plugin_id; self.class.plugin_id; end

    def plugin_revision; self.class.instance_variable_define(:@plugin_revision, 1); end
    def plugin_license; self.class.instance_variable_define(:@plugin_license, :unlicensed); end
    def plugin_author; self.class.instance_variable_define(:@plugin_author, 'gizmore@wechall.net'); end

#    def plugin_module; self.class.name.split('::')[-2]; end # XXX: Is Accessor
    def plugin_name; @_plugin_name ||= self.class.name.split('::').slice(-2, 2).join('/'); end
    def plugin_shortname; @_short_name ||= self.class.name.rsubstr_from('::').undescore.to_sym; end

    def plugin_install; end # before init, depending on revision
    def plugin_init; end # once, on initial loading/reloading
    def plugin_load; end # once, first load 
    def plugin_reload; end # always, on reload
    def plugin_loaded; end  # always, after loaded
    
    def short_class_name; self.class.short_class_name; end
    def self.short_class_name; name.split('::')[-1]; end
    
    ############
    ### Core ###
    ############
    def self.register_instance_variable(varname)
      instance_variables = registered_instance_variables
      instance_variables.push(varname.to_sym) unless instance_variables.include?(varname.to_sym)
    end
    
    def self.registered_instance_variables
      Ricer::Plugin.instance_variable_define(:@instance_variables, [])
    end
    
    def self.clear_registered_instance_variables
      Ricer::Plugin.instance_variable_set(:@instance_variables, [])
    end
    
    def self.register_class_variable(varname)
      class_variables = registered_class_variables
      class_variables.push(varname.to_sym) unless class_variables.include?(varname.to_sym)
    end
    
    def self.registered_class_variables
      Ricer::Plugin.instance_variable_define(:@class_variables, [])
    end
    
    def self.clear_registered_class_variables
      Ricer::Plugin.instance_variable_set(:@class_variables, [])
    end
    
    def self.register_exec_function(funcname)
      register_class_variable(:@exec_functions)
      exec_functions = get_exec_functions
      exec_functions.push(funcname.to_sym) unless exec_functions.include?(funcname.to_sym)
    end
    
    def self.get_exec_functions
      instance_variable_define(:@exec_functions, [])
    end
    
    def self.register_init_function(funcname)
      register_class_variable(:@init_functions)
      init_functions = get_init_functions
      init_functions.push(funcname.to_sym) unless init_functions.include?(funcname.to_sym)
    end
    
    def self.get_init_functions
      instance_variable_define(:@init_functions, [])
    end
    
    ###################
    ### Subcommands ###
    ###################
    attr_accessor :parent_command

    def subcommand_depth
      @subcommand_depth ||= (trigger.to_s.count(' ')+1)
    end

    def subcommand_depth=(depth)
      @subcommand_depth = depth
    end

    ###############
    ### Trigger ###
    ###############
    def default_trigger
      @_default_trigger || _default_trigger
    end
    def _default_trigger
      if self.class.instance_variable_defined?('@default_trigger')
        @_default_trigger = self.class.instance_variable_get('@default_trigger').to_s
      else
        @_default_trigger = self.class.name.rsubstr_from('::').downcase
      end
    end
    
    def i18n_trigger
      begin
        I18n.t!("#{i18n_key}.trigger")
      rescue StandardError => e
        default_trigger
      end
    end
    
    def trigger
      if _pc = parent_command
        _pc.trigger + ' ' + i18n_trigger
      else
        i18n_trigger        
      end
    end
        
    def triggered_by?(argline)
      false
    end
    
    def trigger_permission
      Ricer::Irc::Permission::PUBLIC
    end
    
    def in_scope?
      true
    end
    
    def has_permission?
      true
    end
    
    def has_usage?
      false
    end
    
    def self.merge_options(options, default_options, check_unknowns=true)
      Ricer::Plug::Param.merge_options(options, default_options, check_unknowns)
    end
    
    ##############
    ### Static ###
    ##############
    def self.by_id(id)
      bot.plugins.each{|plugin| return plugin if plugin.id == id } and return nil
    end
    def self.by_arg(arg)
      by_trigger(arg) || by_name(arg)
    end
    def self.subcommand_by_arg(arg, subcommands)
      _by_trigger(arg, subcommands) || _by_name(arg, subcommands)
    end
    def self.by_trigger(trigger)
      _by_trigger(trigger, bot.plugins)
    end
    def self._by_trigger(trigger, plugins)
      plugins.each{|plugin| return plugin if plugin.trigger.to_s == trigger.to_s } and return nil
    end
    def self.by_name(plugin_name)
      _by_name(plugin_name, bot.plugins)
    end
    def self._by_name(plugin_name, plugins)
      plugin_name = plugin_name.to_s
      bot.plugins.each{|plugin| return plugin if plugin.plugin_name == plugin_name } and nil
    end

    # def self.user_plugins(user, scope=:everywhere)
#       
    # end
#     
    # def self.each_user_plugins(user, scope=:everywhere, &block) 
      # plugins.each{|plugin|
#         
      # }
    # end


    #########################
    ### Subcommand by arg ###
    #########################    
    def subcommand_by_arg(arg)
      self.class.subcommand_by_arg(arg, subcommands)
    end
    
    ###################
    ### Exec Bridge ###
    ###################
    def connector_supported?(server)
      true
    end

    def ricer_itself?
      current_message.is_ricer?
    end
    
    def plugins_for_line(line, check_scope=true)
      bot.plugins.select { |plugin|
        plugin.triggered_by?(line)
      }
    end
    
    def plugin_for_line(line, check_scope=true)
      plugins_for_line(line, check_scope)[0] rescue nil
    end
    
    def exec_plugin
      begin
        self.class.get_exec_functions.each do |func|
          send(func)
        end
        unless current_message.forked?
          bot.log_debug("Plugin#exec_plugin is NOT FORKED")
          if current_message.pipe?
            bot.log_debug("Plugin#exec_plugin is PIPING!")
            current_message.pipe!
          elsif current_message.chained?
            bot.log_debug("Plugin#exec_plugin is CHAINING!")
            current_message.chain!
          else
            bot.log_debug("Plugin#exec_plugin is DONE!")
            process_event('ricer_after_execution')
          end
        end
      rescue StandardError => e
        reply_exception e
      end
    end

    def process_event(event_name)
      server.process_event(event_name, current_message)
    end
    
    def event_listeners
      instance_methods.select do |method|
        method.start_with?('ricer_on_') || method.start_with('on_')
      end
    end
    
    ##########################
    ### Exec Line Wrappers ###
    ##########################
    # Execute this plugin with given full line
    # Example: Login#exec_argline("login test")
    def exec_argline(line)
      bot.log_debug("Plugin#exec_argline(#{line})")
      current_message.args[1] = line
      exec_plugin
    end
    
    # Execute a complete new line, like the user would have typed it 
    def exec_newline(line)
      plugin_for_line(line).exec_argline(line)
    end

    ############
    ### I18n ###
    ############
    def description; t(:description); end
    
    #####################
    ### Communication ###
    #####################
    def action_to(target, text); target.send_action(text); end
    def message_to(target, text); target.send_message(text); end
    def notice_to(target, text); target.send_notice(text); end
    def privmsg_to(target, text); target.send_privmsg(text); end
    
  end
end
