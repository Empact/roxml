# Rake libraries used
require "rubygems"
require "rake/runtest"
require "rake/rdoctask"
require "rake/contrib/rubyforgepublisher"
require 'rake/gempackagetask'

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

task :package=>:rdoc
task :rdoc=>:test

desc "Create a RubyGem project"
Rake::GemPackageTask.new(ProjectGemSpec) do |pkg|
end

desc "Clean generated files"
task :clobber=>[:clobber_package, :clobber_rdoc] do |task|
  #
end
