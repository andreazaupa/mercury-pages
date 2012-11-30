$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "mercury-pages/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "mercury-pages"
  s.version     = MercuryPages::VERSION
  s.authors     = ["Lino Moretto"]
  s.email       = ["lino.moretto@develon.com"]
  s.homepage    = "http://www.develon.com"
  s.summary     = "Tiny wrapper around Mercury Editor."
  s.description = "MercuryPages offers a basic persistent storage for web pages and page parts edited with Mercury."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3"
  s.add_dependency "mercury-rails", ">= 0.9.0"
  s.add_dependency "has_foreign_language"
  s.add_dependency "aasm"

  s.add_development_dependency "sqlite3"
end
