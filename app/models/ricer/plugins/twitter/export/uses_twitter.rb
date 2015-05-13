module Ricer::Plug::Extender::UsesTwitter
  def uses_twitter
    class_eval do |klass|
      
      def twitter_plugin
        get_plugin('Twitter/Twitter')
      end
      
      def twitter_client
        twitter_plugin.client
      end
      
    end
  end
end

Ricer::Plugin.extend Ricer::Plug::Extender::UsesTwitter
