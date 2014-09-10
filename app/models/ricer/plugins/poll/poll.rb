###
### Toggles Announce on/off
### Install the plugin
### Close polls automatically
###
module Ricer::Plugins::Poll
  class Poll < Ricer::Plugin

    # Copyright
    def version; 1; end
    def license; nil; end
    def author; 'gizmore'; end
    def since; '27.Jul.2014'; end

    # Its some real plugin to call
    # Toggles Announce on/off
    is_announce_trigger :poll, :user => :public, :channel => :halfop, :channel_default => true

    # Install the plugin
    def upgrade_1; Answer.upgrade_1; Option.upgrade_1; Question.upgrade_1; end
    
    # Max poll options
    has_setting name: :max_options, type: :integer, permission: :responsible, scope: :bot, default: 6, min: 1, max: 10
    def max_options; get_setting(:max_options); end
    
    # Close poll timeout
    has_setting name: :lifetime, type: :duration, permission: :responsible, scope: :bot, default: 2.hours
    def max_age; get_setting(:lifetime); end
    def max_age_cut; Time.now - max_age; end
    
    # Close poll thread    
    def ricer_on_global_startup
      Ricer::Thread.execute do |t|
        loop do 
          sleep 60.seconds
          automatically_close_questions
        end
      end
    end
    
    # Close poll query
    def automatically_close_questions
      Question.open.where('poll_questions.created_at < ?', max_age_cut).each do |question|
        automatically_close_question(question)
      end
    end
    
    # Close poll
    def automatically_close_question(question)
      get_plugin('Poll/Close').close_question(question)
    end

  end
end
