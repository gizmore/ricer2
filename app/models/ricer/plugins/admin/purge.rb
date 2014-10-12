module Ricer::Plugins::Admin
  class Purge < Ricer::Plugin

    trigger_is :purge
    permission_is :responsible

    requires_retype

    has_usage '<plugin>'
    def execute(plugin)
      byebug
      rply :msg_purging
      Ricer::PluginLoader.new(bot).downgrade_plugin(plugin, 0)
      purge_plugin_rows(plugin)
      exec_newline('Admin/Die '+t(:msg_purged_and_die))
    end
    
    private
    
    ###
    ### Delete the plugin inside ricer core tables
    ### Hopefully triggers some other deletes, eg: PluginStats
    ### TODO: Test that
    ###
    def purge_plugin_rows(plugin)
      Ricer::Plugin.where(:bot_id => bot.id).where('name LIKE ?', "#{plugin.plugin_module}/%").each do |p|
        byebug
        p.destroy!
        byebug
      end
    end
    
  end
end
