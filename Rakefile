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
    
    # Set acceptable file permissions for a website.
    files = Dir.entries(WEBSITE_DIR).inject([]) do |m, f|
        m << File.join(WEBSITE_DIR, f) if File.file?(File.join(WEBSITE_DIR, f))
        m
    end
    FileUtils::Verbose.chmod(0664, files) if files && files.length > 0
end 

desc "Clean generated files"
task :clean do |task|
    FileUtils::Verbose.rmtree(BUILD_DIR)
end
