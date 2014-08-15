module Ricer

  class SilentCancel < Exception; end
  class TriggerException < Exception; end
  class ExecutionException < Exception; end

  class Plugin < ActiveRecord::Base
    
    include ActionView::Helpers::NumberHelper

    DEFAULT_PRIORITY = 50
    
    attr_accessor :message, :plugin_module, :plugin_dir, :module_dir
    
    def lib; Ricer::Irc::Lib.instance; end
    def bot; Ricer::Bot.instance; end
    def self.bot; Ricer::Bot.instance; end
    
    def user; @message.sender; end
    def sender; @message.sender; end
    def server; @message.server; end
    def channel; @message.receiver if @message.is_channel?; end
    def args; @message.args; end
    def argv; @message.privmsg_args; end
    def argc; @message.privmsg_args.length; end
    def line; args[1]; end
    def privmsg_line; @message.privmsg_line; end
    def argline
      return @argline unless @argline.nil?
      back = line
      subcommand_depth.times do |n|
        back = back.substr_from(' ').ltrim(' ') rescue back = ''
      end
      @argline = back
      ## .ping a , d1, s1 
      # return nil if line.count(' ') < subcommand_depth
      # return line.split(/ +/, subcommand_depth+1)[-1]
    end
    
    def core_plugin?; false; end
    def priority; self.class.instance_variable_defined?('@priority') ? self.class.instance_variable_get('@priority') : DEFAULT_PRIORITY; end
    def scope; Ricer::Irc::Scope::EVERYWHERE; end
    
    def self.plugin_id; instance_variable_get('@plugin_id'); end
    def plugin_id; self.class.plugin_id; end
    def plugin_revision; 1; end
    def plugin_license; 'MIT'; end
    def plugin_author; 'gizmore@wechall.net'; end
#    def plugin_module; self.class.name.split('::')[-2]; end
    def plugin_name; self.class.name.split('::').slice(-2, 2).join('/'); end
    def plugin_shortname; self.class.name.rsubstr_from('::').undescore.to_sym; end

    def on_init; end
    def on_exit; end
    def on_load; end
    def on_reload; end
    def on_install; end
    
    def short_class_name; self.class.short_class_name; end
    def self.short_class_name; name.split('::')[-1]; end
    
    ############
    ### Core ###
    ############
    def self.register_class_variable(varname)
      class_variables = registered_class_variables
      class_variables.push(varname.to_sym) unless class_variables.include?(varname.to_sym)
      instance_variable_set('@class_variables', class_variables)
    end
    
    def self.registered_class_variables
      instance_variable_defined?('@class_variables') ? instance_variable_get('@class_variables') : []
    end
    
    def self.clear_registered_class_variables
      instance_variable_set('@class_variables', [])
    end
    
    def self.register_exec_function(funcname)
      register_class_variable('@exec_functions')
      exec_functions = get_exec_functions
      exec_functions.push(funcname.to_sym) unless exec_functions.include?(funcname.to_sym)
      instance_variable_set('@exec_functions', exec_functions)
    end
    
    def self.get_exec_functions
      instance_variable_defined?('@exec_functions') ? instance_variable_get('@exec_functions') : []
    end
    
    def self.register_init_function(funcname)
      register_class_variable('@init_functions')
      init_functions = get_init_functions
      init_functions.push(funcname.to_sym) unless init_functions.include?(funcname.to_sym)
      instance_variable_set('@init_functions', init_functions)
    end
    
    def self.get_init_functions
      instance_variable_defined?('@init_functions') ? instance_variable_get('@init_functions') : []
    end
    
    ###################
    ### Subcommands ###
    ###################
    def parent_command
      self.class.instance_variable_get('@parent_command')
    end
    
    def subcommand_depth
      self.class.instance_variable_defined?('@subcommand_depth') ? self.class.instance_variable_get('@subcommand_depth') : 1
    end

    def increase_subcommand_depth(by=1)
      self.class.instance_variable_set('@subcommand_depth', subcommand_depth+by)
    end
    
    ###############
    ### Trigger ###
    ###############
    def default_trigger
      if self.class.instance_variable_defined?('@default_trigger')
        self.class.instance_variable_get('@default_trigger').to_s
      else
        self.class.name.rsubstr_from('::').downcase
      end
    end
    
    def trigger
      begin
        back = I18n.t!("#{i18n_key}.trigger")
      rescue Exception => e
        back = default_trigger
      end
      if subcommand_depth > 1
        back = "#{parent_command.trigger} #{back}" rescue back
      end
      back
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
    
    def self.merge_options(options, default_options, check_unknowns=false)
      Ricer::Plug::Param.merge_options(options, default_options, check_unknowns)
    end
    
    ##############
    ### Static ###
    ##############
    def self.by_arg(arg)
      by_trigger(arg) || by_name(arg)
    end
    
    # def self.by_id(id)
      # bot.plugins.each do |plugin|
        # return plugin if plugin.id == id
      # end
      # nil
    # end

    def self.by_trigger(trigger)
      bot.plugins.each do |plugin|
        return plugin if plugin.trigger.to_s == trigger.to_s
      end
      nil
    end
    
    def self.by_name(plugin_name)
      plugin_name = plugin_name.to_s
      bot.plugins.each do |plugin|
        return plugin if plugin.plugin_name == plugin_name
      end
      nil
    end
    
    ###################
    ### Exec Bridge ###
    ###################
    def connector_supported?(server)
      true
    end

    def ricer_itself?
      @message.is_ricer?
    end
    
    def get_plugin(name)
      Ricer::Plugin.by_name(name).clone_plugin(@message)
    end
    
    def clone_plugin(message)
      back = self.class.new(self.attributes)
#      message.plugin_id = self.id
#      back = self.class.new({id:self.id})
      back.message = message
      back
    end

    def exec_privmsg(message)
      bot.log_debug "Plugin.exec_privmsg #{message.args[1]}"
      # Trim the !
      argline = message.args[1].ltrim(message.trigger_chars)
      # Exec the argline without trim
      exec(argline)
    end
    
    def exec_line(line)
      message = @message.clone
      message.args[1] = line
      clone_plugin(message).exec(line)
    end
    
    def exec(line)
      bot.log_debug "Plugin.exec #{line}"
      plugins_for_line(line).each do |plugin|
        exec_plugin(plugin.clone_plugin(@message))
      end
    end
    
    def plugins_for_line(line, check_scope=true)
      bot.plugins.select { |plugin|; plugin.triggered_by?(line); }
    end
    
    def plugin_for_line(line, check_scope=true)
      plugins_for_line(line, check_scope)[0] rescue nil
    end
    
    def exec_plugin(plugin)
      begin
        plugin.class.get_exec_functions.each do |func|
          plugin.send(func)
        end
      rescue ActiveRecord::NoDatabaseError => e
        bot.running = false
      rescue Exception => e
        plugin.reply_exception e
      end
    end
    
    def process_event(event_name)
      server.process_event(event_name, @message)
    end
    
    def event_listeners
      instance_methods.select do |method|
        method.start_with?('ricer_on_') || method.start_with('on_')
      end
    end
    
    ############
    ### I18n ###
    ############
    def i18n_key; self.class.name.gsub('::', '.').underscore; end
    def i18n_pkey; i18n_key.rsubstr_to('.'); end
    def description; t(:description); end
    def t(key, *args); tt "#{i18n_key}.#{key}", *args; end
    def tp(key, *args); tt "#{i18n_pkey}.#{key}", *args; end
    def tr(key, *args); tt "ricer.#{key}", *args; end
    def tt(key, *args); rt i18t(key, *args); end
    def rt(response)
      response.to_s.
      gsub('$BOT$', server.nickname.name).
      gsub('$COMMAND$', trigger.to_s).
      gsub('$TRIGGER$', server.triggers[0]||'')
    end
    
    # Own I18n.t that rescues into key: arg.inspect
    def i18t(key, *args)
      begin
        I18n.t!(key, *args)
      rescue => e
        bot.log_exception(e)
        i18ti(key, args)
      end
    end
    def i18ti(key, args); "#{key.to_s.rsubstr_from('.')||key}: #{args.inspect.trim('[{}]')}"; end
    
    def l(date, format=:long)
      I18n.l(date, :format => format)
    end
    
    #####################
    ### Communication ###
    #####################
    def action_to(target, text); target.send_action(text); end
    def message_to(target, text); target.send_message(text); end
    def notice_to(target, text); target.send_notice(text); end
    def privmsg_to(target, text); target.send_privmsg(text); end
    
    ##############
    ### IrcLib ###
    ##############
    def bold(text); lib.bold(text); end
    
    ##############
    ### Emails ###
    ##############
    def send_mail(to, subject, body)
      Ricer::Thread.execute do
        BotMailer.generic(to, subject, body).deliver
      end
    end
        
  end
end
