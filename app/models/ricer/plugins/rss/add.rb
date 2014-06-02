module Ricer::Plugins::Rss
  class Add < Ricer::Plugin
    
    trigger_is :add
    
    permission_is :operator
    
    has_usage :execute, '<name> <url>'
    def execute(name, url)

      return rply :err_dup_url unless Feed.by_url(url).nil?
      return rply :err_dup_name unless Feed.by_name(name).nil?
      
      feed = Feed.new({name:name, url:url, user:user})
      
      return rply :err_test unless feed.working?
      
      feed.save!
      
      # Auto Abbo for issuer
      feed.abbonement!(channel == nil ? user : channel)
      
      rply :msg_added, id:feed.id, name:name, title:feed.title, description:feed.description
    end
    
  end
end
