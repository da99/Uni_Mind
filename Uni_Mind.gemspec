# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "Uni_Mind/version"

Gem::Specification.new do |s|
  s.name        = "Uni_Mind"
  s.version     = Uni_Mind::VERSION
  s.authors     = ["da99"]
  s.email       = ["i-hate-spam-45671204@mailinator.com"]
  s.homepage    = ""
  s.summary     = %q{Manage a fleet of servers.}
  s.description = %q{
Manage servers:
  * issue commands
  * update files and keep track of changes
  * create your own "recipes" for servers and server groups
  }

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'bacon'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'Bacon_Colored'
  
  s.add_runtime_dependency  'net-ssh'
  s.add_runtime_dependency  'net-scp'
  s.add_runtime_dependency  'rake'
  s.add_runtime_dependency  'capistrano'
  s.add_runtime_dependency  'differ'
  s.add_runtime_dependency  'term-ansicolor'
  s.add_runtime_dependency  'Uni_Arch', '>= 0.5.0'
  s.add_runtime_dependency  'Unified_IO'
  s.add_runtime_dependency  'Checked', '> 1.0.0'
end
