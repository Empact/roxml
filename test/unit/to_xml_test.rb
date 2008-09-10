require File.join(File.dirname(__FILE__), '..', 'test_helper')

def to_xml_test(*names)
  names = names.only if names.one? && names.only.is_a?(Hash)
  names.each do |(name, xml_name)|
    xml_name ||= name

    define_method "test_#{name}" do
      dict = name.to_s.camelize.constantize.parse(fixture(xml_name))
      xml = xml_fixture(xml_name)
      xml.children.each do |child|
        child.remove! if child.empty?
      end
      assert_equal xml, dict.to_xml
    end
  end
end

class TestHashToXml < Test::Unit::TestCase
  to_xml_test :dictionary_of_attrs, :dictionary_of_mixeds, :dictionary_of_texts
end

class TestOtherToXml < Test::Unit::TestCase
  to_xml_test :book => :book_valid
end