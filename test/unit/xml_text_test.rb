require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestXMLText < Test::Unit::TestCase
  # Test a simple mapping with no composition
  def test_valid_simple
    book = Book.parse(fixture(:book_valid))
    assert_equal("The PickAxe", book.title)
  end

  def test_without_needed_from
    assert !Library.parse(fixture(:library_uppercase)).name
  end

  def test_with_needed_from
    assert_equal "Ruby library", Library.parse(fixture(:library)).name
    assert_equal "Ruby library", UppercaseLibrary.parse(fixture(:library_uppercase)).name
  end

  def test_as_array
    assert_equal ["David Thomas","Andrew Hunt","Dave Thomas"].sort,
                 BookWithAuthors.parse(fixture(:book_with_authors)).authors.sort
  end

  def test_text_modification
    person = Person.parse(fixture(:person))
    assert_equal("Ben Franklin", person.name)
    person.name = "Fred"
    xml=person.to_xml.to_s
    assert(/Fred/=~xml)
  end

  def test_default_initialization
    person = PersonWithMotherOrMissing.parse(fixture(:nameless_ageless_youth))
    assert_equal "Anonymous", person.name
  end

  def test_default_initialization_of_text_content
    person = Person.parse(fixture(:nameless_ageless_youth))
    assert_equal "Unknown", person.name
  end

  def test_recursive_with_default_initialization
    p = PersonWithMotherOrMissing.parse(fixture(:person_with_mothers))
    assert_equal 'Unknown', p.mother.mother.mother.name
  end

  def test_get_with_block
    p = Book.parse(fixture(:book_valid))
    assert_equal 357, p.pages
  end

  def test_no_name_clashes
    n = NodeWithNameConflicts.parse(fixture(:node_with_name_conflicts))
    assert_equal "Just junk... really", n.text_content
    assert_equal "Cartwheel", n.node_name
  end
end