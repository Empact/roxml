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


require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "roxml #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'spec/rake/spectask'
desc "Run specs"
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec' << 'examples'
  spec.spec_opts = ['--options', "spec/spec.opts"]
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

namespace :spec do
  [:libxml, :nokogiri].each do |parser|
    desc "Spec ROXML under the #{parser} parser"
    Spec::Rake::SpecTask.new(parser) do |spec|
      spec.libs << 'lib' << 'spec' << 'examples'
      spec.spec_opts = ['--options=spec/spec.opts']
      spec.spec_files = ["spec/support/#{parser}.rb"] + FileList['spec/**/*_spec.rb']
    end
  end
end

desc "Run specs with rcov"
Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

require 'rake/testtask'
desc "Test ROXML using the default parser selection behavior"
task :test do
  require 'rake/runtest'
  $LOAD_PATH << 'lib'
  Rake.run_tests 'test/unit/*_test.rb'
end

namespace :test do
  desc "Test ROXML under the Nokogiri parser"
  task :nokogiri do
    $LOAD_PATH << 'spec'
    require 'spec/support/nokogiri'
    Rake::Task["test"].invoke
  end

   desc "Test ROXML under the LibXML parser"
  task :libxml do
    $LOAD_PATH << 'spec'
    require 'spec/support/libxml'
    Rake::Task["test"].invoke
  end

  task :load do
    `ruby test/load_test.rb`
    puts "Load Success!" if $?.success?
  end

  desc "Runs tests under RCOV"
  task :rcov do
    system "rcov -T --no-html -x '^/'  #{FileList['test/unit/*_test.rb']}"
  end
end
