module Ricer::Plugins::Stats
  class Plugstats < Ricer::Plugin
    
    trigger_is :plugstats
    
    def upgrade_1; TriggerCounter.upgrade_1; end

    # Count when something is triggered    
    def ricer_on_trigger
      TriggerCounter.count(@message.plugin_id, user.id) rescue nil
    end
    
    ################
    ### Handlers ###
    ################
    has_usage :execute_show_total
    has_usage :execute_show_sum, '<plugin>'
    has_usage :execute_show_topten, '<plugin> <page>'
    has_usage :execute_show_user, '<plugin> <user>'
    
    def execute_show_total
      rply :all_plugins, plugins:bot.plugins.length, total:TriggerCounter.all.summed.first.sum
    end
    
    def execute_show_sum(plugin)
      rply :one_plugin, plugin:plugin.trigger, count:TriggerCounter.for_plugin(plugin).summed.first.sum
    end
    
    def execute_show_topten(plugin, page)
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
    
    def execute_show_user(plugin, user)
      rply :one_plugin_and_user, plugin:plugin.trigger, user:user.displayname, count:TriggerCounter.for_plugin(plugin).for_user(user).first.calls
    end
    
  end
end
