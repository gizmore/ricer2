module Ricer::Plugins::Conf
  class ChannelSet < Ricer::Plugin
    
    trigger_is 'channel set'
    permission_is :responsible
    def config_columns
      Ricer::Irc::Channel.column_names - ['id', 'server_id', 'online', 'name', 'locale_id', 'timezone_id', 'encoding_id', 'created_at', 'updated_at']
    end
    
    # Set a channel db value in private query
    has_usage :execute_set_for, '<channel> <variable> <value>', :scope => :user
    def execute_set_for(channel, var, value)
      columns = config_columns
      return rply :err_channel_column, columns: columns.join(', ') unless columns.include?(var.to_s)
      oldvalue = channel[var]
      channel[var] = value
      channel.save!
      rply :msg_set, channel: channel.displayname, varname: var, value: channel[var], oldvalue: oldvalue
    end
    
    # Set a channel db value in channel itself
    has_usage :execute_set, '<variable> <value>', :scope => :channel
    def execute_set(var, value)
      execute_set_for(self.channel, var, value)
    end

    # Show a channel db value in private query
    has_usage :execute_show_for, '<channel> <variable>', :scope => :user
    def execute_show_for(channel, var)
      columns = config_columns
      return rply :err_channel_column, columns:columns.join(', ') unless columns.include?(var.to_s)
      rply :msg_show, channel: channel.displayname, varname: var, value: channel[var]
    end
    
    # Show a channel db value in channel itself
    has_usage :execute_show, '<variable>', :scope => :channel
    def execute_show(var)
      execute_show_for(self.channel, var)
    end

   # List all db fields for a channel via private query
    has_usage :execute_show_all_for, '<channel>', :scope => :user
    def execute_show_all_for(channel)
      columns = config_columns
      rply :msg_show_all, channel: channel.displayname, columns: columns.join(', ')
    end
  
   # List all db fields for a channel
    has_usage :execute_show_all, '', :scope => :channel
    def execute_show_all()
      execute_show_all_for(self.channel)
    end
    
  end
end
