# Rake libraries used
require "rubygems"
require "rails_plugin_package_task"
require "rake/rdoctask"
require "rake/contrib/rubyforgepublisher"
require "rake/contrib/publisher"
require 'rake/gempackagetask'
require 'rake/testtask'

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
  rd.options << '--main' << 'README.rdoc' << '--title' << 'ROXML Documentation'
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

desc "Install the gem"
task :install => [:package] do
  sh %{sudo gem install pkg/#{spec.name}-#{spec.version}}
end

Rake::TestTask.new(:bugs) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/bugs/*_bugs.rb']
  t.verbose = true
end

@test_files = 'test/unit/*_test.rb'
desc "Test ROXML using the default parser selection behavior"
task :test do
  require 'lib/roxml'
  require 'rake/runtest'
  Rake.run_tests @test_files
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
    system "rcov -T --no-html -x '^/'  #{FileList[@test_files]}"
  end
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
Rake::GemPackageTask.new(spec).define

desc "Clobber generated files"
task :clobber=>[:clobber_package, :clobber_rdoc]
