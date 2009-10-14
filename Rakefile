require 'rake'

ENV['RUBY_FLAGS'] = '-W1'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = 'roxml'
  gem.rubyforge_project = "roxml"
  gem.summary = "Ruby Object to XML mapping library"
  gem.description = <<EOF
ROXML is a Ruby library designed to make it easier for Ruby developers to work with XML.
Using simple annotations, it enables Ruby classes to be mapped to XML. ROXML takes care
of the marshalling and unmarshalling of mapped attributes so that developers can focus on
building first-class Ruby classes. As a result, ROXML simplifies the development of
RESTful applications, Web Services, and XML-RPC.
EOF
  gem.email = "ben.woosley@gmail.com"
  gem.homepage = "http://roxml.rubyforge.org"
  gem.authors = ["Ben Woosley", "Zak Mandhro", "Anders Engstrom", "Russ Olsen"]

  gem.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.rdoc"]

  gem.add_dependency 'activesupport', '>= 2.1.0'
  gem.add_dependency 'libxml-ruby', '>= 1.0.0'

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "sqlite3-ruby", '>= 1.2.4'
  gem.add_development_dependency "activerecord", '>= 2.2.2'
end

Dir['tasks/**/*.rake'].each { |t| load t }

task :default => [:test, :spec]
task :all => [:libxml, :nokogiri]
task :libxml => ['test:libxml', 'spec:libxml']
task :nokogiri => ['test:nokogiri', 'spec:nokogiri']

# $hoe = Hoe.new('roxml', ROXML::VERSION) do |p|
#   p.changes              = File.read("History.txt").split(/^==/)[1].strip
# 
#   p.test_globs = 'test/unit/*_test.rb'
#   p.clean_globs |= %w[**/.DS_Store tmp *.log]
#   path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
#   p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
#   p.rsync_args = '-av --delete --ignore-errors'
# end

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
