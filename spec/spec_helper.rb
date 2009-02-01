require 'pathname'

module ROXML
  SILENCE_XML_NAME_WARNING = true
end

DIR = Pathname.new(__FILE__).dirname
require DIR.join('../lib/roxml').expand_path

def example(name)
  DIR.join("../examples/#{name}.rb").expand_path
end

def xml_for(name)
  DIR.join("../examples/xml/#{name}.xml").expand_path
end