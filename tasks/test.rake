# We need to override hoe's test task in order to support separate REXML & LibXML testing
require  File.join(File.dirname(__FILE__), '../vendor/override_rake_task/lib/override_rake_task')



require 'rake/testtask'
Rake::TestTask.new(:bugs) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/bugs/*_bugs.rb'
  test.verbose = true
end

remove_task :test
desc "Test ROXML using the default parser selection behavior"
task :test do
  module ROXML
    SILENCE_XML_NAME_WARNING = true
  end
  require 'lib/roxml'
  require 'rake/runtest'
  Rake.run_tests 'test/unit/*_test.rb'
end

namespace :test do
  desc "Test ROXML under the LibXML parser"
  task :libxml do
    module ROXML
      XML_PARSER = 'libxml'
    end
    Rake::Task["test"].invoke
  end

  desc "Test ROXML under the REXML parser"
  task :rexml do
    module ROXML
      XML_PARSER = 'rexml'
    end
    Rake::Task["test"].invoke
  end

  desc "Runs tests under RCOV"
  task :rcov do
    system "rcov -T --no-html -x '^/'  #{FileList['test/unit/*_test.rb']}"
  end
end
