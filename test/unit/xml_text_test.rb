require_relative './../test_helper'

class TestXMLText < ActiveSupport::TestCase
  # Test a simple mapping with no composition
  def test_valid_simple
    book = Book.from_xml(fixture(:book_valid))
    assert_equal("The PickAxe", book.title)
    assert_equal("David Thomas, Andrew Hunt & Dave Thomas", book.author)

    assert_equal xml_fixture(:book_valid).to_s.gsub("\n", ''), book.to_xml.to_s.gsub("\n", '')
  end

  def test_without_needed_from
    assert !Library.from_xml(fixture(:library_uppercase)).name
  end

  def test_with_needed_from
    assert_equal "Ruby library", Library.from_xml(fixture(:library)).name
    assert_equal "Ruby library", UppercaseLibrary.from_xml(fixture(:library_uppercase)).name
  end

  def test_as_array
    assert_equal ["David Thomas","Andrew Hunt","Dave Thomas"].sort,
                 BookWithAuthors.from_xml(fixture(:book_with_authors)).authors.sort
  end

  def test_empty_array_result_returned_properly
    empty_array = Class.new do
      include ROXML

      xml_reader :missing_array, :as => [], :from => 'missing'
    end

    obj = empty_array.from_xml('<empty_array></empty_array>')
    assert_equal [], obj.missing_array
  end

  def test_text_modification
    person = Person.from_xml(fixture(:person))
    assert_equal("Ben Franklin", person.name)
    person.name = "Fred"
    xml=person.to_xml.to_s
    assert(/Fred/=~xml)
  end

  def test_default_initialization
    person = PersonWithMotherOrMissing.from_xml(fixture(:nameless_ageless_youth))
    assert_equal "Anonymous", person.name
  end

  def test_default_initialization_of_content
    person = Person.from_xml(fixture(:nameless_ageless_youth))
    assert_equal "Unknown", person.name
  end

  def test_recursive_with_default_initialization
    p = PersonWithMotherOrMissing.from_xml(fixture(:person_with_mothers))
    assert_equal 'Unknown', p.mother.mother.mother.name
  end

  def test_get_with_block
    p = Book.from_xml(fixture(:book_valid))
    assert_equal 357, p.pages
  end

  def test_no_name_clashes
    n = NodeWithNameConflicts.from_xml(fixture(:node_with_name_conflicts))
    assert_equal "Just junk... really", n.content
    assert_equal "Cartwheel", n.name
  end
end