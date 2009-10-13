require 'rubygems'
require 'pathname'

DIR = Pathname.new(__FILE__ + '../..').expand_path.dirname
LOAD_PATH = DIR.join('lib').to_s
$LOAD_PATH.unshift(LOAD_PATH) unless
  $LOAD_PATH.include?(LOAD_PATH) || $LOAD_PATH.include?(File.expand_path(LOAD_PATH))
require 'roxml'

if defined?(Spec)
  require File.join(File.dirname(__FILE__), 'shared_specs')
end

def example(name)
  DIR.join("examples/#{name}.rb")
end

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
  DIR.join("examples/xml/#{name}.xml")
end