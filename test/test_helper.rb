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
  names.each do |name, xml_name|
    xml_name ||= name

    define_method "test_#{name}" do
      klass = name.is_a?(Symbol) ? name.to_s.camelize.constantize : name
      xml = xml_name.is_a?(Symbol) ? xml_fixture(xml_name) : xml_name

      dict = klass.from_xml(xml)
      xml = remove_children(xml)
      assert_equal xml, dict.to_xml
    end
  end
end

def remove_children(xml)
  xml = ROXML::XML::Parser.parse(xml).root if xml.is_a?(String)
  return unless xml.respond_to? :children
  xml.children.each do |child|
    if child.to_s.blank?
      child.remove!
    else
      remove_children(child)
    end
  end
  xml
end