module Ricer::Plugins::Conf
  class ConfChannel < ConfBase
    
    trigger_is :confc
    always_enabled
    
    alias :super_set_var :set_var
    alias :super_show_var :show_var
    alias :super_show_vars :show_vars
    alias :super_show_all_vars :show_all_vars
    
    has_usage :set_var, '<plugin> <variable> <value>', :scope => :channel
    has_usage :show_var, '<plugin> <variable>', :scope => :channel
    has_usage :show_vars, '<plugin>', :scope => :channel

    has_usage :set_var_c, '<channel> <plugin> <variable> <value>', :scope => :user
    has_usage :show_var_c, '<channel> <plugin> <variable>', :scope => :user
    has_usage :show_vars_c, '<channel> <plugin>', :scope => :user

    def config_scope; [:channel]; end
    def config_object; @conf_channel_channel; end 

    def config_channel
      @conf_channel_channel
    end

    def show_all_vars()
      @conf_channel_channel = channel
      super_show_all_vars()
    end

    def show_vars(plugin)
      @conf_channel_channel = channel
      super_show_vars(plugin)
    end 

    def show_var(plugin, varname)
      @conf_channel_channel = channel
      super_show_var(plugin, varname)
    end  

    def set_var(plugin, varname, value)
      @conf_channel_channel = channel
      super_set_var(plugin, varname, value)
    end
  
    def show_all_vars_c(channel)
      @conf_channel_channel = channel
      super_show_all_vars()
    end

    def show_vars_c(channel, plugin)
      @conf_channel_channel = channel
      super_show_vars(plugin)
    end 

    def show_var_c(channel, plugin, varname)
      @conf_channel_channel = channel
      super_show_var(plugin, varname)
    end  

    def set_var_c(channel, plugin, varname, value)
      @conf_channel_channel = channel
      super_set_var(plugin, varname, value)
    end

 end
end
