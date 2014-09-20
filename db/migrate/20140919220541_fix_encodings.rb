class FixEncodings < ActiveRecord::Migration
  def change
    Ricer::Irc::Channel.all.each do |channel|
      channel.encoding = nil
      channel.save!
    end
    Ricer::Irc::User.all.each do |user|
      user.encoding = nil
      user.save!
    end
  end
end
