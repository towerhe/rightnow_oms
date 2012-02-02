$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rightnow_oms/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rightnow_oms"
  s.version     = RightnowOms::VERSION
  s.authors     = ["Tower He"]
  s.email       = ["towerhe@gmail.com"]
  s.homepage    = "http://hetao.im"
  s.summary     = "Manage the orders."
  s.description = "A common mountable engine can be used to manage the orders."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 3.1.3"
  s.add_dependency "acts_as_api"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "capybara"
  s.add_development_dependency "shoulda-matchers"
end
