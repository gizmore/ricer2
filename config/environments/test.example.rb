Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  # RICER2 STUFF. THERE IS ANOTHER SECTION AT THE BOTTOM FOR MAIL #
  # Initial seed for random generator (non crypto)
  config.rice_seeds = 0
  # Set to true for more debug output
  config.chop_sticks = true
  # Set to true for verbose DB Query runtime analysis. there is also "!dbtrace <bool>" plugin to switch that on runtime.
  config.paddy_queries = true
  # Set to true if plugin_loader shall ignore errors
  config.genetic_rice = false
  # owner, but for display only
  config.ricer_owner = 'gizmore'
  # Default server_nickname settings
  config.ricer_hostname = 'ricer.giz.org'
  config.ricer_nickname = 'testrice'
  config.ricer_realname = 'Ricer - The Ruby Chatbot'
  config.ricer_default_server = 'irc://irc.giz.org:6668'
  # END OF RICER2 STUFF

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure static asset server for tests with Cache-Control for performance.
  config.serve_static_assets  = true
  config.static_cache_control = 'public, max-age=3600'

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true


  # Mail SMTP settings  
  # RICER2 STUFF. THIS IS THE SECTION FOR MAIL #
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address => 'ricer.gizmore.org',
    :port => 587,
    :domain => 'ricer.gizmore.org',
    :authentication => :login,
    :user_name => Ricer::Application.secrets.mail_smtp_source,
    :password => Ricer::Application.secrets.mail_smtp_password,
    :openssl_verify_mode => OpenSSL::SSL::VERIFY_NONE,
  }
   # Exception notifier  
  config.middleware.use ExceptionNotifier,
    :email_prefix => "[RicerTest] ",
    :sender_address => %{"RicerBot" <ricer@ricer.gizmore.org>},
    :exception_recipients => (Ricer::Application.secrets.mail_error_rec)end
