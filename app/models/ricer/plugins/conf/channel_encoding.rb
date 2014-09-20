module Ricer::Plugins::Conf
  class ChannelEncoding < Ricer::Plugin
    
    trigger_is :cencoding
    
    has_usage :execute_show, '', scope: :channel 
    has_usage :execute_show, '<channel>'

    has_usage :execute_set, '<encoding>', permission: :operator, scope: :channel 
    has_usage :execute_set_channel, '<channel> <encoding>', permission: :ircop
    
    def execute_show(channel=nil)
      channel ||= self.channel
      have = channel.encoding || channel.server.encoding
      rply(:msg_show,
        iso: have.to_label,
        channel: channel.displayname,
      )
    end

    def execute_set(encoding)
      execute_set_channel(channel, encoding)
    end
    
    def execute_set_channel(channel, encoding)
      have = channel.encoding || channel.server.encoding
      channel.encoding = encoding
      channel.save!
      rply(:msg_set,
        :channel => channel.displayname,
        :old => have.to_label,
        :new => encoding.to_label,
      )
    end

  end
end
