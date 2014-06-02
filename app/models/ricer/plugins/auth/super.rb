module Ricer::Plugins::Auth
  class Super < Ricer::Plugin

    trigger_is :super
    scope_is :user
    permission_is :authenticated
    bruteforce_protected
    
    has_setting name: :password,  scope: :server, permission: :responsible, type: :password
    has_setting name: :superword, scope: :bot,    permission: :responsible, type: :password, default: 'hellricer'
    has_setting name: :magicword, scope: :bot,    permission: :responsible, type: :password, default: 'chickencurry'
    
    has_usage :execute, '<password>'
    def execute(password)
      return elevate(:admin) if get_setting(:password).matches?(password)
      return elevate(:owner) if get_setting(:superword).matches?(password)
      return elevate(:responsible) if get_setting(:magicword).matches?(password)
      rplyp :err_wrong_password
    end
    
    private
    
    def elevate(permission)
      new_permission = user.permission.merge(Ricer::Irc::Permission.by_name(permission))
      user.all_chanperms.each do |chanperm|
        chanperm.permissions = new_permission.bit
        chanperm.save!
      end
      user.permissions = new_permission.bit
      user.save!
      rply :msg_elevated, :permission => new_permission.to_label
    end
  
  end
end
