module Ricer::Plugins::Log
  class Binlog
    
    def self.upgrade_1
      m = ActiveRecord::Migration
      m.create_table :binlogs do |t|
        t.integer  :user_id
        t.integer  :channel_id
        t.string   :input
        t.string   :output
        t.datetime :created_at
      end
    end

    def self.irc_message(message, input)
      create!({
        user_id: message.sender.id,
        channel_id: message.channel_id,
        input: input ? message.raw : nil,
        output: input ? nil : message.reply,
        created_at: irc_message.time,
      })
    end

    def self.channel_log(channel)
    end

  end
end
