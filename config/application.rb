require_relative 'boot'

require 'rails/all'
require 'dotenv/rails'


Bundler.require(*Rails.groups)

Dotenv::Railtie.load if Rails.env.development? || Rails.env.test?

module YourAppName
  class Application < Rails::Application
    config.load_defaults 6.1
    config.assets.enabled = true
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
  end
end
