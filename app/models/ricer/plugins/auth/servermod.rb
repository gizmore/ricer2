module Ricer::Plugins::Auth
  class Servermod < Ricer::Plugin
  
    trigger_is :mods
    
    has_usage :execute_change, '<user> <permission>'
    has_usage :execute_show, '[<user>]'
  
    def execute_show(user)
      user = sender if user.nil?
      rply :msg_mods, 
        user: user.displayname,
        permission: user.permission.display,
        server: user.server.displayname
    end
    
    def change_mods(user, change_permission)
      
      return rplyp :err_unregistered unless user.registered?
      
      old_permission = user.permission
      
      # Check permissions
      sender_permission = sender.permission
      return rplyp :err_permission if sender_permission.may_alter?(old_permission, change_permission)
      
      
      # Change it
      new_permission = old_permission.merge(change_permission)
      result = old_permission.display_change(old_permission, change_permission)
      
      # No change
      return rplyp :msg_no_change if result.nil?
      
      # Changed!
      user.permissions = new_permission.bit      
      user.save!
      return rply :msg_changed, user:user.displayname, permission: result, server:server.displayname
      
    end
  
  end
end
