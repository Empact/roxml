# We need to override hoe's test task in order to support separate REXML & LibXML testing
require  File.join(File.dirname(__FILE__), '../vendor/override_rake_task/lib/override_rake_task')

Rake::TestTask.new(:bugs) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/bugs/*_bugs.rb']
  t.verbose = true
end

remove_task :test
desc "Test ROXML using the default parser selection behavior"
task :test do
  module ROXML
    SILENCE_XML_NAME_WARNING = true
  end
  require 'lib/roxml'
  require 'rake/runtest'
  Rake.run_tests $hoe.test_globs
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
    system "rcov -T --no-html -x '^/'  #{FileList[$hoe.test_globs]}"
  end
end
