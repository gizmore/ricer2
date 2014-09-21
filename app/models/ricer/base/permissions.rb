module Ricer::Base::Permissions

  def in_scope?(scope)
    scope.in_scope?(current_message.scope)
  end
        
  def has_permission?(permission)
    sender = current_message.sender
    channel = current_message.channel
    channel ? 
      sender.has_channel_permission?(channel, permission) :       
      sender.has_permission?(permission)
  end

end
