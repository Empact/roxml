# Rake libraries used
require "rubygems"
require "rake/runtest"
require "rake/rdoctask"
require "rake/contrib/rubyforgepublisher"
require "rake/contrib/publisher"
require 'rake/gempackagetask'
require "rake/contrib/rails_plugin_package_task"

# load settings
require "rakeconfig.rb"

task :default => :test

Rake::RDocTask.new do |rd|
  rd.rdoc_dir = "doc"
  rd.rdoc_files.include("lib/**/*.rb")
end

Rake::RailsPluginPackageTask.new(ProjectInfo[:name], ProjectInfo[:version]) do |p|
  p.package_files = PluginPackageFiles
  p.plugin_files = FileList["rails_plugin/**/*"]
  p.extra_links = {"Project page"=>ProjectInfo[:homepage],
    "Author: #{ProjectInfo[:author_name]}"=>ProjectInfo[:author_link]}
  p.verbose = true
end
task :rails_plugin=>:clobber

desc "Publish Ruby on Rails plug-in on RubyForge"
task :release_plugin=>:rails_plugin do |task|
  pub = Rake::SshDirPublisher.new("#{RubyForgeConfig[:user_name]}@rubyforge.org",
	"/var/www/gforge-projects/#{RubyForgeConfig[:unix_name]}",
	"pkg/rails_plugin")
  pub.upload()
end

desc "Publish and plugin site on RubyForge"
task :publish do |task|
  pub = Rake::RubyForgePublisher.new(RubyForgeConfig[:unix_name], RubyForgeConfig[:user_name])
  pub.upload()
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

desc "Create the plugin package"

task :package=>:rdoc
task :rdoc=>:test

desc "Create a RubyGem project"
Rake::GemPackageTask.new(ProjectGemSpec) do |pkg|
end

desc "Clobber generated files"
task :clobber=>[:clobber_package, :clobber_rdoc] do |task|
  #
end
