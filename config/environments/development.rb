Ricer::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Initial seed for random generator (non crypto)
  config.rice_seeds = 3133735
  # Set to true for more debug output
  config.chop_sticks = true

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true
  config.cache_store = :memory_store, { size: 128.megabytes }

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Mail SMTP settings  
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address => 'ricer.gizmore.org',
    :port => 587,
    :domain => 'ricer.gizmore.org',
    :authentication => :login,
    :user_name => 'ricer@ricer.gizmore.org',
    :password => 'therice',
    :openssl_verify_mode => OpenSSL::SSL::VERIFY_NONE, 
  }
   # Exception notifier  
  config.middleware.use ExceptionNotifier,
    :email_prefix => "[RicerDev] ",
    :sender_address => %{"RicerBot" <ricer@ricer.gizmore.org>},
    :exception_recipients => %w{gizmore@gizmore.org}
end
