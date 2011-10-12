# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ruploy/version"

Gem::Specification.new do |s|
  s.name        = "ruploy"
  s.version     = Ruploy::VERSION
  s.authors     = ["Simon COURTOIS"]
  s.email       = ["scourtois@cubyx.fr"]
  s.homepage    = ""
  s.summary     = %q{Ruploy generates init.d scripts to manage Rack apps using RVM}
  s.description = %q{If you want to manage several Rack apps using different versions of Ruby via RVM, Ruploy can help you. It handles gemsets too !}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "commander"
  s.add_dependency "mustache"
end
