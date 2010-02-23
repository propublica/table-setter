require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "table_setter"
    gem.summary = %Q{A sinatra based app for rendering CSVs hosted on google docs or locally in custom HTML}
    gem.description = %Q{A sinatra based app for rendering CSVs hosted on google docs or locally in custom HTML}
    gem.email = "thejefflarson@gmail.com"
    gem.homepage = "http://github.com/thejefflarson/table-setter"
    gem.authors = ["Jeff Larson"]
    gem.rubyforge_project = "table-setter"
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_dependency "table_fu", ">= 0.1.0"
    gem.add_dependency "mislav-will_paginate", ">= 2.3.11"
    gem.add_dependency "sinatra", ">= 0.9.4"
    gem.add_dependency "sinatra-static-assets", ">= 0.5.0"
    gem.add_dependency "emk-sinatra-url-for", ">= 0.2.1"
    gem.executables << "table-setter"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "rdoc"
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "table-setter #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
