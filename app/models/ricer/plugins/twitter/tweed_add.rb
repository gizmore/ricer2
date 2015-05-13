module Ricer::Plugins::Twitter
  class TweedAdd < Ricer::Plugin
    
    trigger_is 'tweed add'
    permission_is :voice
    
    denial_of_service_protected

    uses_twitter
    
    has_usage '<string>'
    def execute(twitter_screen_name)
      follow = Ricer::Plugins::Twitter::Model::Follow.new({
        name: twitter_screen_name,
        user_id: sender.id,
      })
      service_thread {
        add_hashtag(follow) if follow.is_hashtag?
        add_tweeted(follow) if follow.is_tweeted?
        add_tweeter(follow) if follow.is_tweeter?
      }
    end

    def add_hashtag(follow)
      byebug
      hashtag = follow.name
      tweet = twitter_client.search(follow.search_term).first
      return rply :err_unpopular_tag unless tweet
      follow.attributes = {
#        tweets: twitter_client.search("#{hashtag} -rt").count,
#        retweets: 0,
        last_tweet_id: tweet.id,
        last_tweeter: tweet.user.screen_name,
        last_tweet: tweet.text,
        last_tweeted: tweet.created_at,
      }
      follow.save!
      rply(:msg_added_tag,
        hashtag: hashtag,
        tweet: follow.last_tweet,
        author: follow.last_tweeter,
        date: I18n.l(follow.last_tweeted),
      )
    end

    def add_tweeted(follow)
      hashtag = follow.name
      tweet = twitter_client.search(follow.search_term).first
      return rply :err_unpopular_tag unless tweet
      follow.attributes = {
 #       tweets: twitter_client.search("#{hashtag} -rt").count,
#        retweets: 0,
        last_tweet_id: tweet.id,
        last_tweeter: tweet.user.screen_name,
        last_tweet: tweet.text,
        last_tweeted: tweet.created_at,
      }
      follow.save!
      rply(:msg_added_tweeted,
        tweeted: follow.name,
        tweet: tweet.text,
        author: tweet.user.screen_name,
        date: I18n.l(follow.last_tweeted),
      )
    end

    def add_tweeter(follow)
      tweeter = twitter_client.user(follow.name)
      return rply :err_unknown_user unless tweeter
      sc = tweeter.statuses_count
      follow.attributes = {
        friends: tweeter.friends_count,
        followers: tweeter.followers_count,
        tweets: tweeter.statuses_count,
        retweets: 0, #tweeter.retweet_count,
        last_tweet_id: sc > 0 ? tweeter.status.id : 0,
        last_tweet: sc > 0 ? tweeter.status.text : nil,
        last_tweeted: sc > 0 ? tweeter.status.created_at : nil,
      }
      follow.save!
      if sc > 0
        rply(:msg_added_tweeter,
          tweeter: follow.name,
          friends: follow.friends,
          followers: follow.followers,
          tweet: follow.last_tweet,
          date: I18n.l(follow.last_tweeted),
        )
      else
        rply(:msg_added,
          tweeter: follow.name,
          friends: follow.friends,
          followers: follow.followers,
        )
      end
    end

  end
end
