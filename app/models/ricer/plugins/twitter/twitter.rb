module Ricer::Plugins::Twitter
  class Twitter < Ricer::Plugin
    
    attr_reader :client
    
    has_setting name: :api_key, type: :string, min:8, max:64, scope: :bot, permission: :responsible, default: Ricer::Application.secrets.twitter_api_key
    has_setting name: :api_secret, type: :string, min:8, max:64, scope: :bot, permission: :responsible, default: Ricer::Application.secrets.twitter_api_secret
    has_setting name: :access_token, type: :string, min:8, max:64, scope: :bot, permission: :responsible, default: Ricer::Application.secrets.twitter_access_token
    has_setting name: :access_secret, type: :string, min:8, max:64, scope: :bot, permission: :responsible, default: Ricer::Application.secrets.twitter_access_secret
    
    def upgrade_1
      Ricer::Plugins::Twitter::Model::Follow.upgrade_1
    end
    
    def ricer_on_global_startup
      Ricer::Thread.execute {
        loop {
          bot.log_debug("Sleeping 10 seconds and then...")
          sleep 30.seconds
          check_connection
          poll_tweeds
        }
      }
    end
    
    def check_connection
      @client ||= Object.const_get('Twitter::REST::Client').new do |config|
        config.consumer_key = get_setting(:api_key)
        config.consumer_secret = get_setting(:api_secret)
        config.access_token = get_setting(:access_token)
        config.access_token_secret = get_setting(:access_secret)
      end
    end
    
    def poll_tweeds
      bot.log_debug("Twitter::poll_tweeds")
      Ricer::Plugins::Twitter::Model::Follow.all.active.find_each do |follow|
        begin
          if follow.abbonements.length > 0
            poll_tweed(follow)
            sleep(5.seconds)
          end
        rescue Object::Twitter::Error::Unauthorized => error
          bot.log_error("Twitter Error: #{error}")
          sleep(15.minutes)
          retry 
        rescue Object::Twitter::Error::TooManyRequests => error
          bot.log_error("Twitter Flooding: #{error}. I should retry_after #{error.rate_limit.retry_after}")
          delay = error.rate_limit.reset_in > 0 ? error.rate_limit.reset_in : 900;
          sleep(delay + 10)
          retry
        rescue Object::Twitter::Error::ServiceUnavailable
          sleep(10.minutes)
          retry
        rescue StandardError => e
          bot.log_exception(e)
        end
      end
    end
    
    def poll_tweed(follow)
      bot.log_info("Twitter.poll_tweed(#{follow.name})...")
      client.search(follow.search_term, :since_id => follow.last_tweet_id).reverse_each do |tweet|
        follow.abbonements.find_each do |abbo_target|
          abbo_target.target.localize!.send_message(hashtag_message(follow, tweet))
        end
        if tweet.id > follow.last_tweet_id
          follow.update_from_tweet(tweet)
        end
      end
    end
    
    def hashtag_message(follow, tweet)
      case follow.tweet_type
      when Model::Follow::TWEETAG; key = :msg_new_tweetag
      when Model::Follow::TWEETAT; key = :msg_new_tweetat
      when Model::Follow::TWEETER; key = :msg_new_tweeter
      end
      t(key,
        :hashtag => follow.name,
        :tweet => tweet.text,
        :author => tweet.user.screen_name,
        :date => I18n.l(tweet.created_at),
      )
    end

  end
end
