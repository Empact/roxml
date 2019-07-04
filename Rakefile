require 'rake'

ENV['RUBY_FLAGS'] = '-W1'

Dir['tasks/**/*.rake'].each { |t| load t }

task :default => [:test, :spec]
task :all => [:libxml, :nokogiri, 'spec:active_record']
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
  spec.exclude_pattern = "spec/examples/active_record*_spec.rb"
end

namespace :spec do
  [:libxml, :nokogiri].each do |parser|
    desc "Spec ROXML under the #{parser} parser"
    RSpec::Core::RakeTask.new(parser) do |spec|
      spec.ruby_opts = '-Ilib -Ispec -Iexamples'
      spec.exclude_pattern = "spec/examples/active_record*_spec.rb"
      # spec.spec_files = ["spec/support/#{parser}.rb"] + FileList['spec/**/*_spec.rb']
    end
  end

  desc "Spec ROXML under ActiveRecord"
  RSpec::Core::RakeTask.new(:active_record) do |spec|
    spec.pattern = "spec/examples/active_record*_spec.rb"
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
