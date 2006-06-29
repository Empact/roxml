# Rake libraries used
require "rubygems"
require "rake/runtest"
require "rake/rdoctask"
require "rake/packagetask"
require "rake/contrib/rubyforgepublisher"

# load settings
require "rakeconfig.rb"

task :default => :test

desc "Generate RDoc for the module"
Rake::RDocTask.new do |rd|
  rd.rdoc_dir = "doc"
  rd.rdoc_files.include("lib/**/*.rb")
end

desc "Publish site on RubyForge"
task :publish do |task|
  publisher = Rake::RubyForgePublisher.new(RubyForgeConfig[:unix_name], RubyForgeConfig[:user_name])
  publisher.upload()
end 

desc "Run all the tests"
task :test do |task|
  Rake::run_tests()
end 

desc "Create the ZIP package"
Rake::PackageTask.new(ProjectInfo[:name], ProjectInfo[:version]) do |p|
  p.need_zip = true
  p.package_files = ReleaseFiles
end

desc "Create a release"
task :release=>[:clean,:test,:doc,:package]

desc "Clean generated files"
task :clean do |task|
  FileUtils::Verbose.rmtree("pkg")
end
