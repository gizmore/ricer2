module Ricer::Plugins::Stats
  class Plugstats < Ricer::Plugin
    
    trigger_is :plugstats
    
    def upgrade_1; TriggerCounter.upgrade_1; end
    def ricer_on_trigger; TriggerCounter.count(@message.plugin_id, user.id); end
    
    has_usage
    def execute
      if argc > 0
        plugin = classobject_by_arg(argv[0])
        return rplyr :err_plugin if plugin.nil?
      end
      case argc
      when 0; show_total
      when 1; show_sum(plugin)
      when 2; return show_topten(plugin, argv[1]) if argv[1].numeric?; show_user(plugin, argv[1])
      end
    end
    
    private
    
    def show_total
      rply :all_plugins, plugins:bot.plugins.length, total:TriggerCounter.all.summed.first.sum
    end
    
    def show_sum(plugin)
      rply :one_plugin, plugin:plugin.trigger, count:TriggerCounter.for_plugin(plugin).summed.first.sum
    end
    
    def show_topten(plugin, page)
      out = []
      counters = TriggerCounter.for_plugin(plugin).order('calls DESC').page(page).per(10)
      rank = counters.offset_value
      counters.each do |counter|
        rank += 1
        out.push("#{rank}.#{counter.user.nickname}(x#{counter.calls})")
      end
      return rplyr :err_page if out.length == 0
      rply :toptenpage, plugin:plugin.trigger, page:counters.current_page, pages:counters.total_pages, out:out.join(', ')
    end
    
    def show_user(plugin, username)
      user = load_user(username)
      return rplyr :err_user if user.nil?
      rply :one_plugin_and_user, plugin:plugin.trigger, user:user.displayname, count:TriggerCounter.for_plugin(plugin).for_user(user).first.calls
    end
    
  end
end
