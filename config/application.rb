require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Stocktracker
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Set our custom config values
    config.x.stock_query.start_time_est = '16:05'
    config.x.stock_query.run_every_minutes = 1440;
    config.x.stock_query.url = 'https://www.alphavantage.co/query'    
    config.x.stock_query.function = 'TIME_SERIES_DAILY'
    config.x.stock_query.interval = 'Daily'
    config.x.stock_query.apikey = 'JD3O5AM8Y2NHMMW7'

    # When the server starts schedule our job
    if defined?(Rails::Server)
      config.after_initialize do
        CaptureStockSchedulerJob.schedule        
      end
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
