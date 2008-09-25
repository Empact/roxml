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
  return unless xml.respond_to? :children
  xml.children.each do |child|
    if child.blank?
      child.remove!
    else
      remove_children(child)
    end
  end
end

class TestHashToXml < Test::Unit::TestCase
  to_xml_test :dictionary_of_attrs,
              :dictionary_of_mixeds,
              :dictionary_of_texts,
              :dictionary_of_names,
              :dictionary_of_guarded_names,
              :dictionary_of_name_clashes,
              :dictionary_of_attr_name_clashes
end

class TestOtherToXml < Test::Unit::TestCase
  to_xml_test :book => :book_valid,
              :book_with_author_text_attribute => :book_text_with_attribute,
              :uppercase_library => :library_uppercase

  to_xml_test :book_with_authors,
              :book_with_contributors,
              :book_with_contributions,
              :library,
              :node_with_name_conflicts,
              :node_with_attr_name_conflicts

  to_xml_test :person_with_mother => :person_with_mothers,
              :person_with_guarded_mother => :person_with_guarded_mothers
end

class TestToXmlWithDefaults < Test::Unit::TestCase
  def test_content_and_attr_defaults_are_represented_in_output
    dict = Person.parse(fixture(:nameless_ageless_youth))

    xml = '<person age="21">Unknown</person>'
    assert_equal ROXML::XML::Parser.parse(xml).root, dict.to_xml
  end
end

class TestToXmlWithBlocks < Test::Unit::TestCase
  def test_pagecount_serialized_properly_after_modification
    b = Book.parse(fixture(:book_valid))
    xml = xml_fixture(:book_valid)
    assert_equal '357', xml.search_first('pagecount').content
    assert_equal 357, b.pages

    b.pages = 500
    doc = ROXML::XML::Document.new()
    doc.root = b.to_xml
    assert_equal '500', doc.find_first('pagecount').content
  end
end