# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sheet_mapper/version"

Gem::Specification.new do |s|
  s.name        = "sheet_mapper"
  s.version     = SheetMapper::VERSION
  s.authors     = ["Nathan Esquenazi"]
  s.email       = ["nesquena@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Map google spreadsheets to ruby objects}
  s.description = %q{Map google spreadsheets to ruby objects.}

  s.rubyforge_project = "sheet_mapper"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'google-spreadsheet-ruby', '~> 0.2.1'

  s.add_development_dependency 'minitest', "~> 2.11.0"
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'fakeweb'
  s.add_development_dependency 'awesome_print'
end
