$:.push File.expand_path("../lib", __FILE__)

# Maintain your s.add_development_dependency's version:
require "rightnow_oms/version"

# Describe your s.add_development_dependency and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rightnow_oms"
  s.version     = RightnowOms::VERSION
  s.authors     = ["Tower He"]
  s.email       = ["towerhe@gmail.com"]
  s.homepage    = "http://hetao.im"
  s.summary     = "Manage the orders."
  s.description = "A common mountable engine can be used to manage the orders."

  s.files = Dir["{app,config,db,lib,vendor}/**/*"] + ["Rakefile", "README.rdoc"]

  s.add_dependency "rails"
  s.add_dependency "jquery-rails"
  s.add_dependency "coffee-rails"
  s.add_dependency "sass-rails"
  s.add_dependency "acts_as_api"
  s.add_dependency "ember-rails"
  s.add_dependency "haml-rails"

end
