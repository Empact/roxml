require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestXMLName < Test::Unit::TestCase
  def test_named_books_picked_up
    named = Library.from_xml(fixture(:library))
    assert named.books
    assert_equal :book, named.books.first.tag_name
  end

  def test_nameless_books_missing
    nameless = LibraryWithBooksOfUnderivableName.from_xml(fixture(:library))
    assert nameless.novels.empty?
  end
end