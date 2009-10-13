require 'rubygems'
require 'active_support/test_case'
require 'test/mocks/mocks'
require 'test/mocks/dictionaries'
require 'test/support/fixtures'

def to_xml_test(*names)
  names = names.first if names.size == 1 && names.first.is_a?(Hash)
  names.each do |name, xml_name|
    xml_name ||= name

    define_method "test_#{name}" do
      klass = name.is_a?(Symbol) ? name.to_s.camelize.constantize : name
      xml = xml_name.is_a?(Symbol) ? xml_fixture(xml_name) : xml_name

      dict = klass.from_xml(xml)
      xml = remove_children(xml)
      assert_equal xml.to_s, dict.to_xml.to_s
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