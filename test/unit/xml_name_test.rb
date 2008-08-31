require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestXMLName < Test::Unit::TestCase
  include FixtureHelper

  def test_named_books_picked_up
    named = Library.parse(fixture(:library))
    assert named.books
    assert_equal :book, named.books.first.tag_name
  end

  def test_nameless_books_missing
    nameless = LibraryWithNamelessBooks.parse(fixture(:library))
    assert nameless.books.empty?
  end
end