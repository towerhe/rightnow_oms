source 'http://rubygems.org'

# Declare your gem's dependencies in rightnow_oms.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Used by the dummy application or for test
gem 'jquery-rails'
gem 'ancestry'
gem 'ember-rails'

# The pry ecosystem
gem 'pry'
gem 'pry-nav'
gem 'pry-stack_explorer'
gem 'pry-exception_explorer'

gem 'test_track', git: 'https://github.com/towerhe/test_track.git'

group :assets do
  gem 'uglifier'
  gem 'coffee-rails'
  gem 'sass-rails'
end

group :development, :test do
  gem 'yard'
  gem 'redcarpet'
  gem 'ffaker'
  gem 'therubyracer'
  gem 'mysql2'
end

group :test do
  gem 'plymouth'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'shoulda-matchers'
  gem 'rack_session_access'
  gem 'factory_girl_rails'
  gem 'capybara-webkit'
  gem 'database_cleaner'
  gem 'simplecov', :require => false
end
