$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rustynail/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rustynail"
  s.version     = Rustynail::VERSION
  s.authors     = ["goy"]
  s.email       = ["hyper.go.80@gmail.com"]
  s.homepage    = "https://github.com/goy80/rustynail"
  s.summary     = "make easier to create facet search with Mroonga."
  s.description = "make easier to create facet search with Mroonga."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.21"

end
