# Rake libraries used
require "rubygems"
require "rails_plugin_package_task"
require "rake/runtest"
require "rake/rdoctask"
require "rake/contrib/rubyforgepublisher"
require "rake/contrib/publisher"
require 'rake/gempackagetask'

# load settings
spec = eval(IO.read("roxml.gemspec"))

# Provide the username used to upload website etc.
RubyForgeConfig = {
  :unix_name=>"roxml", 
  :user_name=>"zakmandhro"
}

task :default => :test

Rake::RDocTask.new do |rd|
  rd.rdoc_dir = "doc"
  rd.rdoc_files.include('MIT-LICENSE', 'README.rdoc', "lib/**/*.rb")
  rd.options << '--main' << 'README.rdoc'
end

Rake::RailsPluginPackageTask.new(spec.name, spec.version) do |p|
  p.package_files = FileList[
    "lib/**/*.rb", "*.txt", "README.rdoc", "Rakefile",
    "rake/**/*", "test/**/*.rb", "test/**/*.xml"]
  p.plugin_files = FileList["rails_plugin/**/*"]
  p.extra_links = {"Project page" => spec.homepage,
                   "Author: Zak Mandhro" => 'http://rubyforge.org/users/zakmandhro/'}
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
Rake::PackageTask.new(spec.name, spec.version) do |p|
  p.need_zip = true
  p.package_files = FileList[
    "lib/**/*.rb", "*.txt", "README.rdoc", "Rakefile",
    "rake/**/*","test/**/*.rb", "test/**/*.xml", "html/**/*"]
end

desc "Create the plugin package"

task :package=>:rdoc
task :rdoc=>:test

desc "Create a RubyGem project"
Rake::GemPackageTask.new(spec) do |pkg|
end

desc "Clobber generated files"
task :clobber=>[:clobber_package, :clobber_rdoc] do |task|
  #
end
