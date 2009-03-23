module Enumerable
  undef_method(:one?)
end if [].respond_to?(:one?)

ENV['RUBY_FLAGS'] = '-W1'

%w[rubygems rake rake/clean fileutils newgem rubigen].each { |f| require f }
require File.expand_path(File.dirname(__FILE__) + '/lib/roxml')

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.new('roxml', ROXML::VERSION) do |p|
  p.author = ["Ben Woosley", "Zak Mandhro", "Anders Engstrom", "Russ Olsen"]
  p.email = "ben.woosley@gmail.com"
  p.url = "http://roxml.rubyforge.org"
  p.changes              = File.read("History.txt").split(/^==/)[1].strip
  p.rubyforge_name       = p.name
  p.extra_deps         = [
   ['activesupport','>= 2.1.0'],
   ['libxml-ruby', '= 1.1.2']
  ]
  p.extra_dev_deps = [
    ['newgem', ">= #{::Newgem::VERSION}"],
    ['sqlite3-ruby', '>= 1.2.4' ],
    ['activerecord', '>= 2.2.2' ]
  ]

  p.summary = "Ruby Object to XML mapping library"
  p.description = <<EOF
ROXML is a Ruby library designed to make it easier for Ruby developers to work with XML.
Using simple annotations, it enables Ruby classes to be mapped to XML. ROXML takes care
of the marshalling and unmarshalling of mapped attributes so that developers can focus on
building first-class Ruby classes. As a result, ROXML simplifies the development of
RESTful applications, Web Services, and XML-RPC.
EOF

  p.test_globs = 'test/unit/*_test.rb'
  p.clean_globs |= %w[**/.DS_Store tmp *.log]
  path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
  p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
  p.rsync_args = '-av --delete --ignore-errors'
end

require 'newgem/tasks' # load /tasks/*.rake

Dir['tasks/**/*.rake'].each { |t| load t }

task :default => [:test, :spec]

## Provide the username used to upload website etc.
#RubyForgeConfig = {
#  :unix_name=>"roxml",
#  :user_name=>"zakmandhro"
#}

#Rake::RDocTask.new do |rd|
#  rd.rdoc_dir = "doc"
#  rd.rdoc_files.include('MIT-LICENSE', 'README.rdoc', "lib/**/*.rb")
#  rd.options << '--main' << 'README.rdoc' << '--title' << 'ROXML Documentation'
#end
#
#desc "Publish Ruby on Rails plug-in on RubyForge"
#task :release_plugin=>:rails_plugin do |task|
#  pub = Rake::SshDirPublisher.new("#{RubyForgeConfig[:user_name]}@rubyforge.org",
#      "/var/www/gforge-projects/#{RubyForgeConfig[:unix_name]}",
#      "pkg/rails_plugin")
#  pub.upload()
#end
#
#desc "Publish and plugin site on RubyForge"
#task :publish do |task|
#  pub = Rake::RubyForgePublisher.new(RubyForgeConfig[:unix_name], RubyForgeConfig[:user_name])
#  pub.upload()
#end
#
#desc "Install the gem"
#task :install => [:package] do
#  sh %{sudo gem install pkg/#{spec.name}-#{spec.version}}
#end

#desc "Create the ZIP package"
#Rake::PackageTask.new(spec.name, spec.version) do |p|
#  p.need_zip = true
#  p.package_files = FileList[
#    "lib/**/*.rb", "*.txt", "README.rdoc", "Rakefile",
#    "rake/**/*","test/**/*.rb", "test/**/*.xml", "html/**/*"]
#end
#
#task :package=>:rdoc
#task :rdoc=>:test
#
#desc "Create a RubyGem project"
#Rake::GemPackageTask.new(spec).define
#
#desc "Clobber generated files"
#task :clobber=>[:clobber_package, :clobber_rdoc]
