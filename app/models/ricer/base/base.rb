module Ricer::Base::Base

  def self.included(base)
    base.extend(Ricer::Base::BaseExtend)
  end
  
  GLOBAL_MUTEX = Mutex.new unless defined?(GLOBAL_MUTEX)

  def global_mutex; GLOBAL_MUTEX; end
  
  def bot; Ricer::Bot.instance; end
  def lib; Ricer::Irc::Lib.instance; end
  def plugin_map; Ricer::PluginMap.instance; end

  def class_module; self.class.class_module; end
  
  ###
  # These would work fine, but should be avoided.
  # def channels; Ricer::Irc::Channel; end
  # def servers; Ricer::Irc::Server; end
  # def users; Ricer::Irc::User; end
  #####

  def get_plugin(name); Ricer::Plugin.by_name(name); end

  def current_message; Thread.current[:ricer_message]; end
  def server; current_message.server; end
  
  def send_mail(to, subject, body); Ricer::Thread.execute do; BotMailer.generic(to, subject, body).deliver; end; end
  
end
