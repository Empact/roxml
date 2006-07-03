# Properties for the build.
require 'rake/gempackagetask'

# Provide the username used to upload website etc.
RubyForgeConfig = {
  :unix_name=>"roxml", 
  :user_name=>"zakmandhro"
}

ProjectInfo = {
  :name=>"roxml",
  :description=>"Ruby Object to XML mapping library",
  :homepage=>"http://roxml.rubyforge.org",
  :version=>"1.0",
  :author_link=>"http://rubyforge.org/users/zakmandhro/",
  :author_name=>"Zak Mandhro"
}

ReleaseFiles = FileList[
  "lib/**/*.rb", "**/*.txt", "**/README", "**/Rakefile", "**/rakeconfig.rb",
  "rake/**/*","test/**/*.rb", "test/**/*.xml", "doc/**/*", "html/**/*"
].exclude(/\bCVS\b|~$/)

PluginPackageFiles = FileList[
  "lib/**/*.rb", "**/*.txt", "**/README", "**/Rakefile", "**/rakeconfig.rb",
  "rake/**/*","test/**/*.rb", "test/**/*.xml"
].exclude(/\bCVS\b|~$/)
 
GemFiles = FileList[
  "lib/**/*.rb", "**/*.txt", "test/**/*", "test/**/*.xml", "doc/**/*"
].exclude(/\bCVS\b|~$/)

ProjectGemSpec = Gem::Specification.new do |s|
 s.name = ProjectInfo[:name]
 s.summary = ProjectInfo[:description]
 s.version = ProjectInfo[:version]
 s.homepage = ProjectInfo[:homepage]
 s.platform = Gem::Platform::RUBY
 s.author = "Zak Mandhro"
 s.files = GemFiles
 s.requirements << 'none'
 s.require_path = 'lib'
 s.test_file = "test/test_roxml.rb"
 s.has_rdoc = true
 s.autorequire = 'roxml'
 s.description = <<EOF
ROXML is a Ruby library designed to make it easier for Ruby developers to work with XML.
Using simple annotations, it enables Ruby classes to be mapped to XML. ROXML takes care
of the marshalling and unmarshalling of mapped attributes so that developers can focus on
building first-class Ruby classes. As a result, ROXML simplifies the development of 
RESTful applications, Web Services, and XML-RPC.
EOF
end
