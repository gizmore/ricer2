namespace :ricer do
  
  desc "Install and launch the ricer bot."
  task(:install, [:botid] => [:environment]) do |t, args|
    puts "Running migrations and seed."
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:seed'].invoke
    bot = ricer_rake_init(args, true)
    bot.log_info "Installing ricer bot##{bot.id}."
    bot.log_info "Ricer bot ##{bot.id} has been installed."
  end
  
  desc "Startup the ricer bot."
  task(:start, [:botid] => [:environment]) do |t, args|
    bot = ricer_rake_init(args)
    bot.log_info "Starting up ricer bot##{bot.id}."
    bot.load_plugins
    bot.log_info "Raisins!"
    bot.run
  end
  
  desc "Create monster langfiles for languages except en."
  task(:translate, [:botid] => :environment) do |t, args|
    bot.log_info "Loading the ricer bot."
    bot = ricer_rake_init(args, true)
    bot.log_info "Updating translation files."
    # Fire the translator
    bot.export_translations    
    bot.log_info "Done. Thx for flying ricer!"
  end
  
  desc "Add an irc server. bundle exec rake ricer:irc[ircs://irc.gizmore.org:6666,ricer,,1]"
  task(:irc, [:url, :nick, :pass, :botid] => [:environment]) do |t, args|
    bot = ricer_rake_init(args)
    args.with_defaults(
      :url => Ricer::Application.config.ricer_default_server,
      :nick => Ricer::Application.config.ricer_nickname,
      :pass => '',
    )
    args.pass = nil if args.pass.trim.empty?
    # ActiveRecord::Base.logger = Logger.new(STDOUT)
    server = Ricer::Irc::Server.in_domain(args[:url]).first
    if server
      url = server.server_url
      nick = server.server_nicks.first
      nick.nickname = args[:nick]
    else
      server ||= Ricer::Irc::Server.new({bot_id: bot.id})
      server.server_url = url = Ricer::Irc::ServerUrl.new({server: server, url: args[:url]})
      server.server_nicks.push(nick = Ricer::Irc::ServerNick.new({server_id: server.id, nickname: args[:nick]}))
    end
    ricer_rake_save_server(server)
    bot.log_info("IRC config saved for Ricer##{bot.id}. Server: #{server.id}: #{server.name} URL: #{url.id}-#{url.domain}. Nick: ##{nick.id}-#{nick.nickname}")
  end
  
  desc "Add a netcat socket server. ricer:tcp[1,31342,0.0.0.0,ricer,botid1]"
  task(:tcp, [:maxnum, :port, :ip, :nick, :botid] => [:environment]) do |t, args|
    ricer_rake_new_listener(:tcp, args)
  end

  desc "Add a websocket server. ricer:websocket[1,31344,0.0.0.0,ricer,botid1]"
  task(:tcp, [:maxnum, :port, :ip, :nick, :botid] => [:environment]) do |t, args|
    ricer_rake_new_listener(:websocket, args)
  end
  
  # desc "Add an ICQ account. ricer:icq[276647844,thepass,ricer,botid1]"
  # task(:icq, [:uin, :pass, :nick, :botid] => :environment) do |t, args|
    # throw "Need uin" unless args.uin && args.uin.integer?
    # throw "Need pass" unless args.pass
    # args.with_defaults(
      # :nick => Ricer::Application.config.ricer_nickname || 'ricer',
      # :botid => Ricer::Application.config.rice_ean || 1,
    # )
    # pid = spawn "bundle exec rake ricer:violet[icq,#{args.uin},#{args.pass},#{args.nick},#{args.botid}]"
    # Process.detach(pid)
  # end
  
  ### BEGIN PURPLE
  desc "Add a purple account. E.g.: bundle exec rake ricer:violet[icq,276657844,foobabaz]"
  task(:violet, [:connector, :pos, :login, :pass, :nick, :botid] => :environment) do |t, args|
    bot = ricer_rake_init(args, true)
    bot.log_info("Configure violet #{args.connector} for #{args.login}")
    throw "Need violet purple login!" unless args.login
    throw "Need violet purple password!" unless args.pass
    args.with_defaults(
      :connector => nil,
      :pos => 0,
      :nick => Ricer::Application.config.ricer_nickname || 'ricer',
      :botid => Ricer::Application.config.rice_ean || 1,
    )
    con = bot.get_connector(args.connector.to_sym)
    throw "Unknown violet purple connector: #{args.connector}" unless con
    pos = args.pos.to_i rescue -1
    throw "2nd parameter 'pos' not between 0 and 100: #{args.pos}" unless pos.between?(0,100)
    servers = Ricer::Irc::Server.with_connector(:connector)
    
    server = servers.with_login(args.nick).first
    server = servers.offset(pos).first unless server
    if (pos == 0) && server.nil?
      server = ricer_rake_new_server(bot.id, args.connector, nil, args.nick, args.login, args.pass, 0.5, 100)
    end
    url = server.server_url
    nick = server.server_nicks.first
    nick.username = args.login
    nick.password = args.pass
    nick.nickname = args.nick
    url.url = con.new(server).default_url
    url.save!
    nick.save!
    server.save!
    bot.log_info("Purple connector violet-#{args.connector} saved for Ricer##{bot.id}. Server: #{server.id}: #{server.name} URL: #{url.id}-#{url.domain}. Nick: ##{nick.id}-#{nick.username}")
  end
  ### END PURPLE
end
### END namespace

###
###
###
###

def ricer_rake_new_listener(connector, args)
  bot = ricer_rake_init(args, true)
  con = bot.get_connector(connector) or throw "Unknown connector: #{connector}"
  args.with_defaults(
    :maxnum => 1,
    :ip => '0.0.0.0',
    :port => 31342,
    :nick => Ricer::Application.config.ricer_nickname,
  )
  maxnum = args.maxnum.to_i rescue 0
  throw "IP is missing or invalid: #{args.ip}" unless URI::Generic.is_ip?(args.ip)
  throw "Port is missing or invalid: #{args.port}" unless URI::Generic.is_port?(args.port)
  throw "Maxnum is missing or invalid: #{args.maxnum}" unless maxnum.between?(1,100)
  #
  url = "tcp://#{args.ip}:#{args.port}"
  # Get server
  servers = Ricer::Irc::Server.where(:connector => :tcp)
  server = servers.with_url_like(":#{args.port}").first
  server = servers.last if server.nil? && (servers.count >= maxnum) 
  if server
    server.server_nicks.first.nickname = args.nick
    server.server_url.url = url
  else
    server = ricer_rake_new_server(bot.id, :tcp, url, args.nick, 0.5, 100)
  end
  url = server.server_url
  nick = server.server_nicks.first
  url.save!(validate: false)
  nick.save!
  server.save!
  bot.log_info("Listener saved: #{args.connector} for Ricer##{bot.id}. Server: #{server.id}: #{server.name} URL: #{url.id}-#{url.domain}. Nick: ##{nick.id}-#{nick.username}")
end

def ricer_rake_new_server(botid, connector, url=nil, nick=nil, user=nil, pass=nil, cooldown=0.5, throttle=50)
  Ricer::Irc::Server.new({
    bot_id: botid,
    connector: connector.to_s,
    cooldown: cooldown,
    throttle: throttle,
    server_url: Ricer::Irc::ServerUrl.new({
      url: url,
    }),
    server_nicks: [Ricer::Irc::ServerNick.new({
      username: user,
      password: pass,
      nickname: nick,
    })],
  })
end

def ricer_rake_save_server(server)
  bot = server.bot;
  bot.log_info "I have saved: #{server.id}-#{server.name} with #{server.server_url.url}"
  bot.log_debug "Server: #{server.to_json}"
  bot.log_debug "SRVURL: #{server.server_url.to_json}"
end

def ricer_rake_load_plugins(bot)
  bot.log_info "Loading plugins..."
  bot.botlog.silently {
    bot.load_plugins
  }
end

def ricer_rake_init(args={}, load_plugins=false)
  # Supported Languages
  Ricer::Application.config.rice_origin.each do |iso|
    Ricer::Locale.find_or_create_by(iso: iso)
  end
  # All Encodings
  Ricer::Encoding.create(iso: 'UTF-8') unless Ricer::Encoding.exists?('UTF-8')
  Encoding.list.each do |encoding|
    Ricer::Encoding.find_or_create_by(iso: encoding.name)
  end
  # All Timezones
  Ricer::Timezone.create(iso: 'Berlin') unless Ricer::Timezone.exists?('Berlin')
  ActiveSupport::TimeZone.all.each do |timezone|
    Ricer::Timezone.find_or_create_by(iso: timezone.name)
  end

  # Create the bot
  botid =  args[:botid] || Ricer::Application.config.rice_ean || 1
  bot = Ricer::Bot.find_or_create_by(:id => botid)
  bot.init
  ricer_rake_load_plugins(bot) if load_plugins
  bot
end
