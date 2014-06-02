# Supported Languages
['en', 'de', 'fam', 'bot', 'ibdes'].each do |iso|
  Ricer::Locale.create(iso: iso) unless Ricer::Locale.exists?(iso)
end

# All Encodings
Ricer::Encoding.create(iso: 'UTF-8') unless Ricer::Encoding.exists?('UTF-8')
Encoding.list.each do |encoding|
  Ricer::Encoding.create(iso: encoding.name) unless Ricer::Encoding.exists?(encoding.name)
end

# All Timezones
Ricer::Timezone.create(iso: 'Berlin') unless Ricer::Timezone.exists?('Berlin')
ActiveSupport::TimeZone.all.each do |timezone|
  Ricer::Timezone.create(iso: timezone.name) unless Ricer::Timezone.exists?(timezone.name)
end




### ---

bot = Ricer::Bot.create()
server = Ricer::Irc::Server.create({bot_id:bot.id})
url = Ricer::Irc::ServerUrl.create({server_id:server.id, url:'irc://irc.giz.org:6668'})
nick = Ricer::Irc::ServerNick.create({server_id:server.id, nickname:'ricer'})

