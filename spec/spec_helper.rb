require 'rubygems'
require 'pathname'

DIR = Pathname.new(__FILE__ + '../..').expand_path.dirname
require 'lib/roxml'

if defined?(Spec)
  require 'spec/shared_specs'
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