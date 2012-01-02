# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "seabright/version"

Gem::Specification.new do |s|
  s.name        = "seabright"
  s.version     = Seabright::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["John Bragg"]
  s.email       = ["john@seabrightstudios.com"]
  s.homepage    = ""
  s.summary     = %q{Seabright general lib.}
  s.description = %q{}

  s.rubyforge_project = "seabright"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency "closure-compiler"
  s.add_dependency "base64"
end
