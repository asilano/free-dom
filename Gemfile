source 'http://rubygems.org'

gem 'rails', '3.1.0'
gem 'i18n'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

group :production do
  gem 'pg'
  gem 'thin'
end
group :development, :test do
  gem 'sqlite3'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

gem 'jquery-rails'
gem 'therubyracer'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

# Remove when moved to modern jQuery
gem 'prototype_legacy_helper', '0.0.0', :git => 'http://github.com/rails/prototype_legacy_helper.git'
gem 'prototype-rails'#, :git => 'http://github.com/rails/prototype-rails.git'

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'minitest'
  gem 'shoulda'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'launchy'  
end
