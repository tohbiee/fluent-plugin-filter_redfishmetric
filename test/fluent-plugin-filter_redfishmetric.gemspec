# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require ('./lib/fluent/plugin/version.rb')

Gem::Specification.new do |s|
  s.name        = "fluent-plugin-filter_redfishmetric"
  s.version     = "0.0.3"
  s.authors     = ["XX SXXX"]
  s.email       = ["XXXX"]
  s.homepage    = "https://github.com/tohbiee/redfish_fluentd_filter"
  s.summary     = "A Fluentd filter plugin to rettrieve selected redfish metric"
  s.description = s.summary
  s.licenses    = ["XXX"]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "fluentd", ">= 0.12"
  s.add_development_dependency "rake"
  s.add_development_dependency "test-unit"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-nav"
end