require_relative './../test_helper'

class TestHashToXml < ActiveSupport::TestCase
  to_xml_test :dictionary_of_attrs,
              :dictionary_of_mixeds,
              :dictionary_of_texts,
              :dictionary_of_names,
              :dictionary_of_guarded_names,
              :dictionary_of_name_clashes,
              :dictionary_of_attr_name_clashes
end

class TestOtherToXml < ActiveSupport::TestCase
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

class TestToXmlWithDefaults < ActiveSupport::TestCase
  def test_content_and_attr_defaults_are_represented_in_output
    dict = Person.from_xml(fixture(:nameless_ageless_youth))

    xml = '<person age="21">Unknown</person>'
    assert_equal ROXML::XML.parse_string(xml).root.to_s, dict.to_xml.to_s
  end
end

class TestToXmlWithBlocks < ActiveSupport::TestCase
  def test_pagecount_serialized_properly_after_modification
    b = Book.from_xml(fixture(:book_valid))
    xml = xml_fixture(:book_valid)
    assert_equal '357', xml.roxml_search('pagecount').first.content
    assert_equal 357, b.pages

    b.pages = 500
    doc = ROXML::XML::Document.new()
    doc.root = b.to_xml
    assert_equal '500', doc.roxml_search('pagecount').first.content
  end
end

class OctalInteger
  def self.from_xml(val)
    new(Integer(val.content))
  end

  def initialize(value)
    @val = value
  end

  def ==(other)
    @val == other
  end

  def to_xml
    sprintf("%#o", @val)
  end
end

class BookWithOctalPages
  include ROXML

  xml_accessor :pages_with_to_xml_proc, :as => Integer, :to_xml => proc {|val| sprintf("%#o", val) }, :required => true
  xml_accessor :pages_with_type, :as => OctalInteger, :required => true
end

class TestToXmlWithOverriddenOutput < ActiveSupport::TestCase
  to_xml_test :book_with_octal_pages
end
