require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dominion
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.autoload_paths << Rails.root.join('lib')
    config.action_view.embed_authenticity_token_in_remote_forms = true

    config.assets.precompile += %w<games.css users.css game_board.css rankings.css legacy/stylesheets/application.css>
  end
end

ActionMailer::Base.smtp_settings = {
  :address              => ENV['MAIL_SERV'],
  :port                 => ENV['MAIL_PORT'],
  :domain               => ENV['MAIL_DOM'],
  :user_name            => ENV['MAIL_USER'],
  :password             => ENV['MAIL_PASS'],
  :authentication       => "plain",
  :enable_starttls_auto => true
}

ThemesForRails.config do |config|
  # themes_dir is used to allow ThemesForRails to list available themes. It is not used to resolve any paths or routes.
  config.themes_dir = ":root/app/assets/themes"

  # assets_dir is the path to your theme assets.
  config.assets_dir = ":root/app/assets/themes/:name"

  # views_dir is the path to your theme views
  config.views_dir =  ":root/app/views/themes/:name"

  # themes_routes_dir is the asset pipeline route base.
  # Because of the way the asset pipeline resolves paths, you do
  # not need to include the 'themes' folder in your route dir.
  #
  # for example, to get application.css for the default theme,
  # your URL route should be : /assets/default/stylesheets/application.css
  config.themes_routes_dir = "assets"
end