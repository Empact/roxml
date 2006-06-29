# Properties for the build.

# Provide the username used to upload website etc.
RubyForgeConfig = {
  :unix_name=>"roxml", 
  :user_name=>"zakmandhro"
}

ProjectInfo = {
  :name=>"roxml",
  :version=>"1.0_beta"
}

ReleaseFiles = FileList[
  "lib/**/*.rb", "**/*.txt", "**/Rakefile", "**/rakeconfig.rb",
  "test/**/*.rb", "test/**/*.xml", "doc/**/*", "html**/*"
].exclude(/\bCVS\b|~$/)
