require 'simplecov'
SimpleCov.start 'rails'

require "rack_session_access"
require "rack_session_access/capybara"

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

require 'ffaker'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara-webkit'
require 'shoulda-matchers'
require 'pry'
require 'factory_girl_rails'
require 'database_cleaner'

Capybara.javascript_driver = :webkit

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each {|f| require f}

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.infer_base_class_for_anonymous_controllers = false

  config.include RightnowOms::Engine.routes.url_helpers

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
  end

  config.before(:each) do
    if Capybara.current_driver == :rack_test
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start
    else
      DatabaseCleaner.strategy = :truncation
    end
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
