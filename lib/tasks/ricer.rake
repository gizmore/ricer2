namespace :ricer do
  
  desc "Startup the ricer bot."
  task(:start => :environment) do
    
    bot = Ricer::Bot.find(1)
    
    bot.log_info "Starting up the ricer bot."
    bot.init
    bot.load_plugins

    bot.log_info "Raisins!"
    bot.run

  end
  
  desc "Create monster langfiles for languages except en."
  task(:translate => :environment) do
    
    bot = Ricer::Bot.find(1)

    bot.log_info "Loading the ricer bot."
    bot.init
    bot.load_plugins

    bot.log_info "Updating translation files."

    # Fire the translator    
    translator = Translator::Translator.new(:en)
    targets = []
    Ricer::Locale.all.each{|locale| targets.push(locale.iso.to_sym) unless locale.iso == "en"}
    translator.generate(targets)
    
    bot.log_info "Done. Thx for flying ricer!"
    
  end
end
