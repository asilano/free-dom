source 'http://rubygems.org'

ruby '2.4.5'
gem 'rails', '~> 4.2.0'
gem 'i18n'

gem 'activerecord-session_store'

group :production do
  gem 'pg', '~> 0.11'
  gem 'newrelic_rpm'
  #gem 'unicorn'
  gem 'puma'
  gem 'rails_12factor'
end
group :development, :test do
  gem 'sqlite3'
  gem "quiet_assets"
  gem "better_errors", '~> 1.0'
  gem "binding_of_caller"

  gem 'thin'
end

# Gems used only for assets and not required
# in production environments by default.
#group :assets do
  gem 'sass-rails'
  gem 'compass-rails'
  gem 'sassy-buttons'
  gem 'sass'
  gem 'coffee-rails'
  gem 'uglifier'
#end

gem 'jquery-rails', :path => "vendor/gems/jquery-rails-3.1.4"
#gem 'therubyracer'
gem 'actionmailer-with-request'
gem 'slim-rails'

gem 'figaro'
gem 'andand'
gem 'squeel'

gem 'acts_as_tree'

gem 'themes_for_rails'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'minitest'
  gem 'shoulda'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'launchy'

  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
end
