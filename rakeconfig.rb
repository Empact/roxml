# Properties for the build.
require 'rake/gempackagetask'

# Provide the username used to upload website etc.
RubyForgeConfig = {
  :unix_name=>"roxml", 
  :user_name=>"zakmandhro"
}

ReleaseFiles = FileList[
  "lib/**/*.rb", "*.txt", "README.rdoc", "Rakefile", "rakeconfig.rb",
  "rake/**/*","test/**/*.rb", "test/**/*.xml", "html/**/*"
].exclude(/\bCVS\b|~$/)

PluginPackageFiles = FileList[
  "lib/**/*.rb", "*.txt", "README.rdoc", "Rakefile", "rakeconfig.rb",
  "rake/**/*", "test/**/*.rb", "test/**/*.xml"
].exclude(/\bCVS\b|~$/)
 
GemFiles = FileList[
  "lib/**/*.rb", "*.txt", "README.rdoc", 'MIT-LICENSE', "test/**/*", "test/**/*.xml"
].exclude(/\bCVS\b|~$/)