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

# The one and only ricer table entry?
# It is actually possible (in theory) to have multiple instances in the db, but no ricer:start for that yet :)
# TODO: find_or_create_with(id:1) in ricer:start
bot = Ricer::Bot.create!()

##### Default Server(s) ######

# ICQ Server (known as ICQ/Oscar/AIM)
#if Ricer::Application.config.ricer_icq_enabled
#  server = Ricer::Irc::Server.create!({bot_id:bot.id, connector: 'icq'})
#  url = Ricer::Irc::ServerUrl.create!({server_id:server.id, url: 'login.icq.com:5910'})
#  nick = Ricer::Irc::ServerNick.create({server_id:server.id, nickname:'697570787', password:'YourMom2'})
#end

# Websocket
#server = Ricer::Irc::Server.create!({bot_id:bot.id, connector: 'websocket'})
#url = Ricer::Irc::ServerUrl.create!({server_id:server.id, url: 'ws://0.0.0.0:31337'})
#nick = Ricer::Irc::ServerNick.create({server_id:server.id, nickname:Ricer::Application.config.ricer_nickname, password:'YourMom2'})

# IRC Server
### ---
# TODO: Make this a rake task!
server = Ricer::Irc::Server.create({bot_id:bot.id})
url = Ricer::Irc::ServerUrl.create({server_id:server.id, url:Ricer::Application.config.ricer_default_server})
nick = Ricer::Irc::ServerNick.create({server_id:server.id, nickname:Ricer::Application.config.ricer_nickname})
