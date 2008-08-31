require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestXMLText < Test::Unit::TestCase
  include FixtureHelper

  # Test a simple mapping with no composition
  def test_valid_simple
    book = Book.parse(fixture(:book_valid))
    assert_equal("The PickAxe", book.title)
  end

  def test_xml_text_without_needed_from
    assert !Library.parse(fixture(:library_uppercase)).name
  end

  def test_xml_text_with_needed_from
    assert_equal "Ruby library", Library.parse(fixture(:library)).name
    assert_equal "Ruby library", UppercaseLibrary.parse(fixture(:library_uppercase)).name
  end

  def test_xml_text_as_array
    assert_equal ["David Thomas","Andrew Hunt","Dave Thomas"].sort,
                 BookWithAuthors.parse(fixture(:book_with_authors)).authors.sort
  end

  def test_text_modificatoin
    person = Person.parse(fixture(:person))
    assert_equal("Ben Franklin", person.name)
    person.name = "Fred"
    xml=person.to_xml.to_s
    assert(/Fred/=~xml)
  end
end