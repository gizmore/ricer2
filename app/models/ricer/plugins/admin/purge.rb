module Ricer::Plugins::Admin
  class Purge < Ricer::Plugin

    trigger_is :purge
    permission_is :responsible
    requires_retype

    has_usage :execute, '<plugin>'
    def execute(plugin)
      byebug
      rply :msg_purging
      purge_plugin_tables(plugin)
      purge_plugin_rows(plugin)
      exec_newline('Admin/Die '+t(:msg_purged_and_die))
    end
    
    private

    ###
    ### Delete all tables from all ActiveRecords inside module dir
    ###
    def purge_plugin_tables(plugin)
      Filewalker.traverse_files(plugin.plugin_dir, '*.rb') do |path|
        purge_plugin_table(plugin, path)
      end
    end

    def purge_plugin_table(plugin, path)
      klass = const_get(purge_klass(plugin, path)) rescue return
      return unless klass < ActiveRecord::Base
      begin
        m = ActiverRecord::Migration.new
        m.drop_table klass.table_name
      rescue StandardError => e
        bot.log_exception(e)
      end
    end
    
    def purge_klass(plugin, path)
      byebug
      plugin_dir = plugin.plugin_dir # app/models/ricer/plugins/admin
      plugin_dir = plugin.plugin_dir.substr_from('/models/ricer/plugins/') # app/models/ricer/plugins/admin
      plugin_dir.modulize!
      byebug
    end
    
    ###
    ### Delete the plugin inside ricer core tables
    ### Hopefully triggers some other deletes, eg: PluginStats
    ### TODO: Test that
    ###
    def purge_plugin_rows(plugin)
      Ricer::Plugin.where(:bot_id => bot.id).where('name LIKE ?', "#{plugin.plugin_module}/%").each do |p|
        byebug
        p.destroy!
      end
    end
    
  end
end
