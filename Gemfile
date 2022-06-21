source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby `cat ./.ruby-version`

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.0'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 4.3'
# Use SCSS for stylesheets
gem 'sassc-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Peg sprockets-rails to avoid whine about precompiles scss in prod
gem 'sprockets-rails', '~> 2.3.3'

gem 'autoprefixer-rails'
gem 'foundation-rails', '~> 6.0'
gem 'foundation_rails_helper', '~> 4.0'
gem 'jquery-rails'
gem 'slim-rails'
gem 'sortable-rails'
gem "stimulus-rails"
gem "turbo-rails"
gem 'webpacker', '~> 5.x'

gem 'inline_svg'

gem 'devise'

gem 'discordrb-webhooks'

# for railties app_generator_test
gem "bootsnap", ">= 1.1.0", require: false

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'

  # Adds support for Capybara system testing and selenium driver
  gem 'capybara'
  gem 'webdrivers'

  gem 'rspec-rails'
  gem 'rspec-collection_matchers'
  gem 'factory_bot_rails'
  gem 'guard'
  gem 'guard-rspec'
  gem 'spring-commands-rspec'
  gem 'simplecov', require: false
  gem 'mutant-rspec'

  gem "rails_stats"
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  #gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'rails_real_favicon'
end

group :test do
  gem 'turnip'
end
