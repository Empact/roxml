require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestXMLAttribute < Test::Unit::TestCase
  include FixtureHelper

  def test_mutable_attr
    book = Book.parse(fixture(:book_text_with_attribute))
    assert !book.isbn.empty?
    assert book.respond_to? :'isbn='
  end
end