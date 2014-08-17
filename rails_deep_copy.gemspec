$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rails_deep_copy/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rails_deep_copy"
  s.version     = RailsDeepCopy::VERSION
  s.authors     = ["Ryan Francis"]
  s.email       = ["ryan@launchpadlab.com"]
  s.homepage    = "http://www.github.com/launchpadlab/rails_deep_copy"
  s.summary     = "Creates a deep duplicate of any active record object, its infinitely deep descendants, and reassigns their foreign keys appropriately."
  s.description = ""
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails"

  s.add_development_dependency "sqlite3"
end
