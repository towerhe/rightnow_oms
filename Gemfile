source "http://rubygems.org"

# Declare your gem's dependencies in rightnow_oms.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Used by the dummy application or for test
gem "jquery-rails"
gem 'ancestry'
gem "ember-rails"

group :assets do
  gem "uglifier"
  gem "coffee-rails"
  gem "sass-rails"
end

group :development, :test do
  gem "ffaker"
  gem 'therubyracer'
  gem "sqlite3"
  gem "pry"
end

group :test do
  gem "rspec-rails"
  gem "capybara"
  gem "shoulda-matchers"
  gem "rack_session_access"
  gem 'factory_girl_rails'
end

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
