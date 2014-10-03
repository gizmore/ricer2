require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Ricer
  class Application < Rails::Application
    
    # Initial seed for random generator (non crypto)
    config.rice_seeds = 12345
    # Set to true for more debug output
    config.chop_sticks = true
    # Set to true if plugin_loader shall ignore errors
    config.genetic_rice = true

    # Rails autoload directories
    config.autoload_paths += %W["#{config.root}/app/validators/"]
    
    # Cache and stuff
    #config.action_controller.perform_caching = true
    config.active_record.partial_writes = true
    config.active_record.attribute_types_cached_by_default = [] # :date, :time, :datetime, :timestamp
    config.cache_classes = true
#    config.allow_concurrency = true
    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Berlin'
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en
    config.i18n.fallbacks = [:en]
    I18n.enforce_available_locales = false
    config.i18n.enforce_available_locales = false
    
    config.ricer_name = 'Ricer'
    config.ricer_owner = 'gizmore'
    config.ricer_version = '0.98a'
    config.ricer_version_date = Time.new(2014, 10, 3, 11, 17, 23)

  end
end
