require "lib/roxml"
require 'test/mocks/mocks'
require 'test/mocks/dictionaries'

def fixture(name)
  File.read(fixture_path(name))
end

def xml_fixture(name)
  ROXML::XML::Parser.parse_file(fixture_path(name)).root
end

def fixture_path(name)
  "test/fixtures/#{name}.xml"
end

def to_xml_test(*names)
  names = names.only if names.one? && names.only.is_a?(Hash)
  names.each do |(name, xml_name)|
    xml_name ||= name

    define_method "test_#{name}" do
      dict = name.to_s.camelize.constantize.from_xml(fixture(xml_name))
      xml = xml_fixture(xml_name)
      remove_children(xml)
      assert_equal xml, dict.to_xml
    end
  end
end

def remove_children(xml)
  return unless xml.respond_to? :children
  xml.children.each do |child|
    if child.blank?
      child.remove!
    else
      remove_children(child)
    end
  end
end