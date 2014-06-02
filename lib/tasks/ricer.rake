namespace :ricer do
  desc "Startup the ricer bot"
  task(:start => :environment) do
    
    bot = Ricer::Bot.find(1)
    
    bot.log_info "Starting up the ricer bot."
    bot.init
    bot.load_plugins

    bot.log_info "Raisins!"
    bot.run

  end
end
