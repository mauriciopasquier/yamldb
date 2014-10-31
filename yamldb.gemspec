# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yamldb/version'

Gem::Specification.new do |s|
  s.platform      = Gem::Platform::RUBY
  s.name          = "yamldb"
  s.version       = Yamldb::VERSION
  s.authors       = ["Adam Wiggins", "Orion Henry"]
  s.summary       = %q{yamldb allows export/import of database into/from yaml files}
  s.description   = "\nYamldb is a database-independent format for dumping and restoring data.  It complements the the database-independent schema format found in db/schema.rb.  The data is saved into db/data.yml.\nThis can be used as a replacement for mysqldump or pg_dump, but only for the databases typically used by Rails apps.  Users, permissions, schemas, triggers, and other advanced database features are not supported - by design.\nAny database that has an ActiveRecord adapter should work.\n"
  s.homepage      = "https://github.com/yamldb/yamldb"
  s.license       = "MIT"

  s.extra_rdoc_files = ["README.md"]
  s.files = Dir['README.md', 'init.rb', 'lib/**/*']
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 1.8.7"

  s.add_runtime_dependency "rails", ">= 3.0", "< 4.3"
  s.add_runtime_dependency "rake"

  s.add_development_dependency "bundler"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "sqlite3"
end
