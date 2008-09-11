require File.join(File.dirname(__FILE__), '..', 'test_helper')

def to_xml_test(*names)
  names = names.only if names.one? && names.only.is_a?(Hash)
  names.each do |(name, xml_name)|
    xml_name ||= name

    define_method "test_#{name}" do
      dict = name.to_s.camelize.constantize.parse(fixture(xml_name))
      xml = xml_fixture(xml_name)
      remove_children(xml)
      assert_equal xml, dict.to_xml
    end
  end
end

def remove_children(xml)
  xml.children.each do |child|
    if child.empty?
      child.remove!
    else
      remove_children(child)
    end
  end
end

class TestHashToXml < Test::Unit::TestCase
  to_xml_test :dictionary_of_attrs, :dictionary_of_mixeds, :dictionary_of_texts
end

class TestOtherToXml < Test::Unit::TestCase
  to_xml_test :book => :book_valid,
              :book_with_author_text_attribute => :book_text_with_attribute,
              :uppercase_library => :library_uppercase

  to_xml_test :book_with_authors,
              :book_with_contributors,
              :book_with_contributions,
              :library

  to_xml_test :person_with_mother => :person_with_mothers,
              :person_with_guarded_mother => :person_with_guarded_mothers
end

class TestToXmlWithDefaults < Test::Unit::TestCase
  def test_text_content_and_attr_defaults_are_represented_in_output
    dict = Person.parse(fixture(:nameless_ageless_youth))

    xml = '<person age="21">Unknown</person>'
    assert_equal LibXML::XML::Parser.string(xml).parse.root, dict.to_xml
  end
end