namespace :ricer do
  
  desc "Install and launch the ricer bot."
  task(:install, [:botid] => [:environment]) do |t, args|
    puts "Running migrations and seed."
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:seed'].invoke
    bot = ricer_rake_init(args)
    bot.log_info "Installing ricer bot##{bot.id}."
    bot.load_plugins
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
    
    bot = ricer_rake_init(args)

    bot.log_info "Loading the ricer bot."
    bot.load_plugins

    bot.log_info "Updating translation files."

    # Fire the translator
    bot.export_translations    
    
    bot.log_info "Done. Thx for flying ricer!"
    
  end
  
  desc "Add an irc server"
  task(:irc, [:url, :nick, :pass, :botid] => [:environment]) do |t, args|
    bot = ricer_rake_init(args)
    args.with_defaults(
      :url => Ricer::Application.config.ricer_default_server,
      :nick => Ricer::Application.config.ricer_nickname,
      :pass => nil
    )
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
    url.save!
    nick.save!
    server.save!
    bot.log_info("IRC config saved for Ricer##{bot.id}. Server: #{server.id}: #{server.name} URL: #{url.id}-#{url.domain}. Nick: ##{nick.id}-#{nick.nickname}")
  end
  
  # desc "Add a netcat socket server. ricer:tcp[1,31342,0.0.0.0,ricer,botid1]"
  # task(:tcp, [:maxnum, :port, :ip, :nick, :botid] => [:environment]) do |t, args|
    # args.with_defaults(
      # :ip => '0.0.0.0',
      # :port => 31342,
      # :nick => Ricer::Application.config.ricer_nickname,
    # )
  # end
  
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
  
  desc "Add a purple account."
  task(:violet, [:connector, :login, :pass, :nick, :botid] => :environment) do |t, args|
    bot = ricer_rake_init(args)
    bot.log_info("Configure violet #{args.connector} for #{args.login}")
    throw "Need violet purple login!" unless args.login
    throw "Need violet purple password!" unless args.pass
    args.with_defaults(
      :nick => Ricer::Application.config.ricer_nickname || 'ricer',
      :botid => Ricer::Application.config.rice_ean || 1,
    )
    bot.load_plugins
    server = nil
    Ricer::Irc::Server.where(:connector => args.connector).each do |s|
      server = s if s.server_nicks.first.username = args.login
    end

    if server
      nick = server.server_nicks.first
      nick.username = args.login
      nick.password = args.pass
      nick.nickname = args.nick
    else
      server = Ricer::Irc::Server.new({
        bot_id: bot.id,
        connector: args.connector,
        cooldown: 0.5,
        throttle: 50,
        server_url: Ricer::Irc::ServerUrl.new({
          url: nil # later
        }),
        server_nicks: [Ricer::Irc::ServerNick.new({
          username: args.login,
          password: args.pass,
          nickname: args.nick,
        })],
      })
    end
    url = server.server_url
    nick = server.server_nicks.first
    con = bot.get_connector(args.connector.to_sym)
    throw "Unknown violet purple connector: #{args.connector}" unless con
    url.url = con.new(server).default_url
    url.validate!
    server.save!
    bot.log_info("Purple connector violet-#{args.connector} saved for Ricer##{bot.id}. Server: #{server.id}: #{server.name} URL: #{url.id}-#{url.domain}. Nick: ##{nick.id}-#{nick.username}")
  end
end





def ricer_rake_init(args={})
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
  bot
end
