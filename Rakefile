require 'rake'

ENV['RUBY_FLAGS'] = '-W1'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
require 'juwelier'
Juwelier::Tasks.new do |gem|
  gem.name = 'roxml'
  gem.summary = "Ruby Object to XML mapping library"
  gem.description = <<EOF
ROXML is a Ruby library designed to make it easier for Ruby developers to work with XML.
Using simple annotations, it enables Ruby classes to be mapped to XML. ROXML takes care
of the marshalling and unmarshalling of mapped attributes so that developers can focus on
building first-class Ruby classes. As a result, ROXML simplifies the development of
RESTful applications, Web Services, and XML-RPC.
EOF
  gem.email = "ben.woosley@gmail.com"
  gem.homepage = "https://github.com/Empact/roxml"
  gem.authors = ["Ben Woosley", "Zak Mandhro", "Anders Engstrom", "Russ Olsen"]

  gem.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.rdoc"]
end
Juwelier::GemcutterTasks.new

Dir['tasks/**/*.rake'].each { |t| load t }

task :default => [:test, :spec]
task :all => [:libxml, :nokogiri]
task :libxml => ['test:libxml', 'spec:libxml']
task :nokogiri => ['test:nokogiri', 'spec:nokogiri']


require 'rdoc/task'
RDoc::Task.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "roxml #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'rspec/core/rake_task'
desc "Run specs"
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.ruby_opts = '-Ilib -Ispec -Iexamples'
  # spec.spec_files = FileList['spec/**/*_spec.rb']
end

namespace :spec do
  [:libxml, :nokogiri].each do |parser|
    desc "Spec ROXML under the #{parser} parser"
    RSpec::Core::RakeTask.new(parser) do |spec|
      spec.ruby_opts = '-Ilib -Ispec -Iexamples'
      # spec.spec_files = ["spec/support/#{parser}.rb"] + FileList['spec/**/*_spec.rb']
    end
  end
end

desc "Run specs with rcov"
RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.rcov = true
  spec.ruby_opts = '-Ilib -Ispec -Iexamples'
  # spec.spec_files = FileList['spec/**/*_spec.rb']
end

require 'rake/testtask'
desc "Test ROXML using the default parser selection behavior"
Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*_test.rb']
end

namespace :test do
  desc "Test ROXML under the Nokogiri parser"
  task :nokogiri do
    $LOAD_PATH << '.'
    require 'spec/support/nokogiri'
    Rake::Task["test"].invoke
  end

   desc "Test ROXML under the LibXML parser"
  task :libxml do
    $LOAD_PATH << '.'
    require 'spec/support/libxml'
    Rake::Task["test"].invoke
  end

  desc "Runs tests under RCOV"
  task :rcov do
    system "rcov -T --no-html -x '^/'  #{FileList['test/unit/*_test.rb']}"
  end
end
