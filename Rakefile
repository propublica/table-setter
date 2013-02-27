require 'bundler/gem_tasks'

task :test do
  Dir['./test/*_test.rb'].each do |file|
    ruby file
  end
end
task :default => :test

desc "render documentation for gh-pages"
task :gh do
 require 'erb'
 File.open("index.html", "w") do |f|
   f.write ERB.new(File.open("documentation/index.html.erb").read).result
 end
 `open index.html`
end

desc "Publish the docs to gh-pages"
task :publish do |t|
  system('git push -f origin master:gh-pages')
end
