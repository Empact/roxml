require 'rake/testtask'
Rake::TestTask.new(:bugs) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/bugs/*_bugs.rb'
  test.verbose = true
end

desc "Test ROXML using the default parser selection behavior"
task :test do
  require 'rake/runtest'
  Rake.run_tests 'test/unit/*_test.rb'
end

namespace :test do
  desc "Test ROXML under the Nokogiri parser"
  task :nokogiri do
    module ROXML
      XML_PARSER = 'libxml'
    end
    Rake::Task["test"].invoke
  end

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
