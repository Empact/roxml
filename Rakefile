# Rakefile for roxml        -*- ruby -*-


require 'fileutils'
require 'rake/contrib/sshpublisher'

config = {
    :rubyforge_username => nil
}

# Try to load the Rake.config file if it exist and update the default
# config.

if File.exist?('Rake.config')
    File.read('Rake.config').each_line do |line|
        next if line =~ /^\s*$/ || line =~ /^\s*#/
        name, value = line.split("=")
        config[name.strip.to_sym] = value.strip
    end
end

BUILD_DIR = "build"
DOC_SRC_DIR = "doc-src"
WEBSITE_DIR = "#{BUILD_DIR}/website"


task :default => :website

desc "Generate the website from BlueCloth"
task :website do |task|
    
    ruby %{-I tools/bluecloth tools/docgen/docgen.rb #{DOC_SRC_DIR} #{WEBSITE_DIR}}
    # Copy CSS
    css = File.join(DOC_SRC_DIR, "css", "style.css")
    if File.exist?(css)
        FileUtils::Verbose.cp(css, WEBSITE_DIR)
    end
    
end 

task :publish_website => :website do |task|
    raise "No rubyforge username specified!" unless config[:rubyforge_username]    
    pub = Rake::SshDirPublisher.new("#{config[:rubyforge_username]}@roxml.rubyforge.org", "/var/www/gforge-projects/roxml", WEBSITE_DIR)
    pub.upload
    
end

desc "Clean generated files"
task :clean do |task|
    FileUtils::Verbose.rmtree(BUILD_DIR)
end
