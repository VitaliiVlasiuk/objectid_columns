# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'objectid_columns/version'

Gem::Specification.new do |spec|
  spec.name          = "objectid_columns"
  spec.version       = ObjectidColumns::VERSION
  spec.authors       = ["Andrew Geweke"]
  spec.email         = ["ageweke@swiftype.com"]
  spec.summary       = %q{Transparently store MongoDB ObjectId values in ActiveRecord.}
  spec.homepage      = "https://www.github.com/swiftype/objectid_columns"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  ar_version = ENV['OBJECTID_COLUMNS_AR_TEST_VERSION']
  ar_version = ar_version.strip if ar_version

  spec.add_dependency("activerecord", ">= 5.0")
  spec.add_dependency("activesupport", ">= 5.0")

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14"
  spec.add_development_dependency "moped", "~> 1.5" unless RUBY_VERSION =~ /^1\.8\./
  spec.add_development_dependency "bson", "~> 1.9"
  spec.add_development_dependency "composite_primary_keys"

  require File.expand_path(File.join(File.dirname(__FILE__), 'spec', 'objectid_columns', 'helpers', 'database_helper'))
  database_gem_name = ObjectidColumns::Helpers::DatabaseHelper.maybe_database_gem_name

  # Ugh. Later versions of the 'mysql2' gem are incompatible with AR 3.0.x; so, here, we explicitly trap that case
  # and use an earlier version of that Gem.
  if database_gem_name && database_gem_name == 'mysql2' && ar_version && ar_version =~ /^3\.0\./
    spec.add_development_dependency('mysql2', '~> 0.2.0')
  else
    spec.add_development_dependency(database_gem_name)
  end

  # Double ugh. Basically, composite_primary_keys -- as useful as it is! -- is also incredibly incompatible with so
  # much stuff:
  #
  # * Under Ruby 1.9+ with Postgres, it causes binary strings sent to or from the database to get truncated
  #   at the first null byte (!), which completely breaks binary-column support;
  # * Under JRuby with ActiveRecord 3.0, it's completely broken;
  # * Under JRuby with ActiveRecord 3.1 and PostgreSQL, it's also broken;
  # * Under JRuby with ActiveRecord 4.1 and SQLite, it's also broken.
  #
  # In these cases, we simply don't load or test against composite_primary_keys; our code is good, but the interactions
  # between CPK and the rest of the system make it impossible to run those tests. There is corresponding code in our
  # +basic_system_spec+ to exclude those combinations.
end
