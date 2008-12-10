require File.join(File.dirname(__FILE__), '..', 'test_helper')

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

  to_xml_test :book_with_wrapped_attr
end

class TestToXmlWithDefaults < Test::Unit::TestCase
  def test_content_and_attr_defaults_are_represented_in_output
    dict = Person.from_xml(fixture(:nameless_ageless_youth))

    xml = '<person age="21">Unknown</person>'
    assert_equal ROXML::XML::Parser.parse(xml).root, dict.to_xml
  end
end

class TestToXmlWithBlocks < Test::Unit::TestCase
  def test_pagecount_serialized_properly_after_modification
    b = Book.from_xml(fixture(:book_valid))
    xml = xml_fixture(:book_valid)
    assert_equal '357', xml.search('pagecount').first.content
    assert_equal 357, b.pages

    b.pages = 500
    doc = ROXML::XML::Document.new()
    doc.root = b.to_xml
    assert_equal '500', doc.search('pagecount').first.content
  end
end