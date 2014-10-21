source 'http://rubygems.org'
source 'http://gems.github.com'

ruby '1.9.3'
gem 'rails', '3.1.10'
gem 'i18n'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

group :production do
  gem 'pg'
  gem 'thin'
  gem 'newrelic_rpm'
  gem 'unicorn'
  gem 'rails_12factor'
end
group :development, :test do
  gem 'sqlite3'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "   3.1.5"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

gem 'jquery-rails', :path => "vendor/gems/jquery-rails-1.0.19"
#gem 'therubyracer'
gem 'actionmailer-with-request'
gem 'haml'

gem 'andand'

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

  gem 'cucumber-rails'
  gem 'database_cleaner'
end
