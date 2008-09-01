require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestXMLAttribute < Test::Unit::TestCase
  include FixtureHelper

  def test_mutable_attr
    book = Book.parse(fixture(:book_text_with_attribute))
    assert !book.isbn.empty?
    assert book.respond_to?(:'isbn=')
  end

  def test_default_initialization
    person = PersonWithMotherOrMissing.parse(fixture(:nameless_ageless_youth))
    assert_equal 21, person.age
  end

  def test_recursive_with_default_initialization
    p = PersonWithMotherOrMissing.parse(fixture(:person_with_mothers))
    assert_equal 21, p.mother.mother.mother.age
  end
end