require "lib/roxml"
require "test/unit"
require 'test/mocks'
require 'test/mocks/dictionaries'

def fixture(name)
  File.read(fixture_path(name))
end

def xml_fixture(name)
  LibXML::XML::Parser.file(fixture_path(name)).parse.root
end

def fixture_path(name)
  "test/fixtures/#{name.to_s}.xml"
end

def to_xml_test(*names)
  names.each do |name|
    define_method "test_#{name}" do
      dict = name.to_s.camelize.constantize.parse(fixture(name))
      assert_equal xml_fixture(name), dict.to_xml
    end
  end
end