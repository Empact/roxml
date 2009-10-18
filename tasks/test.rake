require 'rake/testtask'
desc "Test ROXML using the default parser selection behavior"
task :test do
  require 'rake/runtest'
  Rake.run_tests 'test/unit/*_test.rb'
end

namespace :test do
  desc "Test ROXML under the Nokogiri parser"
  task :nokogiri do
    module ROXML
      XML_PARSER = 'nokogiri'
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

  task :load do
    `ruby test/load_test.rb`
    puts "Load Success!" if $?.success?
  end

  desc "Runs tests under RCOV"
  task :rcov do
    system "rcov -T --no-html -x '^/'  #{FileList['test/unit/*_test.rb']}"
  end
end
