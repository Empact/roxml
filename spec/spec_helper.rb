require 'pathname'

module ROXML
  SILENCE_XML_NAME_WARNING = true
end

DIR = Pathname.new(__FILE__).dirname
require DIR.join('../lib/roxml').expand_path

def example(name)
  DIR.join("../examples/#{name}.rb").expand_path
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'roxml'

require File.join(File.dirname(__FILE__), 'shared_specs')

def fixture(name)
  File.read(fixture_path(name))
end

def xml_fixture(name)
  ROXML::XML::Parser.parse_file(fixture_path(name)).root
end

def fixture_path(name)
  "test/fixtures/#{name}.xml"
end

def xml_for(name)
  DIR.join("../examples/xml/#{name}.xml").expand_path
end