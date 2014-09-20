module Ricer::Base::Permissions

  def in_scope?(scope)
    scope.in_scope?(current_message.scope)
  end
        
  def has_permission?(trigger_permission)
    current_permission.has_permission?(trigger_permission, respect_permission)
  end

  def respect_permission
    return Ricer::Irc::Permission::REGISTERED if current_message.is_query?
    return current_message.sender.chanperm_for(current_message.channel).permission
  end
  
  def current_permission
    sender = current_message.sender
    return sender.permission if current_message.is_query?
    return sender.chanperm_for(current_message.channel).merged_permission
  end

end
