#
# Simple tool that generates a website from a number of
# BlueCloth formatted text files.
#

require 'bluecloth'

INPUT_DIR = ARGV[0]
OUTPUT_DIR = ARGV[1]
PROJECT_NAME = ARGV[2]
PAGE_TITLE_PREFIX = (PROJECT_NAME ? PROJECT_NAME+"::" : "")

raise "Invalid startup parameters!" unless (INPUT_DIR || OUTPUT_DIR)

if File.exist?(OUTPUT_DIR) && File.file?(OUTPUT_DIR)
    raise "Output path exists and is a regular file!"
end

unless File.exist?(OUTPUT_DIR)
    puts "Output directory does not exist. Creating..."
    require 'fileutils'
    FileUtils.makedirs(OUTPUT_DIR)
end

# Collect the information.
struct = Dir.entries(INPUT_DIR).inject([]) do |memo, entry|
    if File.file?(File.join(INPUT_DIR, entry)) && entry !~ /^\./
        memo << [
            File.join(INPUT_DIR, entry), #Input file
            File.join(OUTPUT_DIR, entry.downcase) + ".html", #Output file
            entry.capitalize # Title of page
        ]
    end
    memo
end

# Declare a HTML template
HTML_DOC = %{
<html>
    <head><title>%s</title></head>
    <body>
        %s
    </body>
</html>
}

# Create the output
struct.each do |input, output, name|
    content = File.read(input)
    
    # TODO: Preprocess
    
    File.open(output, "w") do |f|
        f.puts HTML_DOC % [PAGE_TITLE_PREFIX + name, BlueCloth.new(content).to_html]
    end
end

