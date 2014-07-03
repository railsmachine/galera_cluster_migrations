# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'galera_cluster_migrations/version'

Gem::Specification.new do |spec|
  spec.name          = "galera_cluster_migrations"
  spec.version       = GaleraClusterMigrations::VERSION
  spec.authors       = ["Bryan Traywick"]
  spec.email         = ["bryan@railsmachine.com"]
  spec.summary       = %q{RSU database migrations for MariaDB Galera Cluster.}
  spec.description   = %q{Rolling Schema Upgrade (RSU) database migrations for MariaDB Galera Cluster.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", ">= 3.0.0"
  spec.add_runtime_dependency "activerecord", ">= 3.0.0"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
