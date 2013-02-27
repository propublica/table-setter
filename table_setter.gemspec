# -*- encoding: utf-8 -*-
require File.expand_path('../lib/table_setter/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = %q{table_setter}
  gem.version = TableSetter::VERSION

  gem.authors = ["Jeff Larson"]
  gem.date = %q{2012-03-09}
  gem.description = %q{A sinatra based app for rendering CSVs hosted on google docs or locally in custom HTML}
  gem.email = %q{thejefflarson@gmail.com}
  gem.executables = ["table-setter", "table-setter"]

  gem.files         = `git ls-files`.split($\).reject {|f| f =~ /^(index)/}
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.name          = "daybreak"
  gem.require_paths = ["lib"]
  gem.licenses      = ["MIT"]
  gem.homepage = %q{http://propublica.github.com/table-setter/}
  gem.require_paths = ["lib"]
  gem.summary = %q{A sinatra based app for rendering CSVs in custom HTML}

  gem.add_development_dependency %q<minitest>
  gem.add_dependency %q<rack>
  gem.add_dependency %q<thin>
  gem.add_dependency %q<table_fu>
  gem.add_dependency %q<sinatra>
  gem.add_dependency %q<sinatra-static-assets>
  gem.add_dependency %q<emk-sinatra-url-for>
  gem.add_dependency %q<curb>
  gem.add_dependency %q<rdiscount>
end

