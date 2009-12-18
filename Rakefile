require 'rake'

ENV['RUBY_FLAGS'] = '-W1'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = 'roxml'
  gem.rubyforge_project = "roxml"
  gem.summary = "Ruby Object to XML mapping library"
  gem.description = <<EOF
ROXML is a Ruby library designed to make it easier for Ruby developers to work with XML.
Using simple annotations, it enables Ruby classes to be mapped to XML. ROXML takes care
of the marshalling and unmarshalling of mapped attributes so that developers can focus on
building first-class Ruby classes. As a result, ROXML simplifies the development of
RESTful applications, Web Services, and XML-RPC.
EOF
  gem.email = "ben.woosley@gmail.com"
  gem.homepage = "http://roxml.rubyforge.org"
  gem.authors = ["Ben Woosley", "Zak Mandhro", "Anders Engstrom", "Russ Olsen"]

  gem.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.rdoc"]

  gem.add_dependency 'activesupport', '>= 2.3.0'
  gem.add_dependency 'nokogiri', '>= 1.3.3'

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "sqlite3-ruby", '>= 1.2.4'
  gem.add_development_dependency "activerecord", '>= 2.2.2'
end
Jeweler::GemcutterTasks.new
Jeweler::RubyforgeTasks.new do |rubyforge|
  rubyforge.doc_task = "rdoc"
end

Dir['tasks/**/*.rake'].each { |t| load t }

task :default => [:test, :spec, 'test:load']
task :all => [:libxml, :nokogiri, 'test:load']
task :libxml => ['test:libxml', 'spec:libxml']
task :nokogiri => ['test:nokogiri', 'spec:nokogiri']
