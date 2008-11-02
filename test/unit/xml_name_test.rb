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

  def test_tag_name
    assert_equal :dictionary, DictionaryOfTexts.tag_name

    dict = DictionaryOfTexts.from_xml(fixture(:dictionary_of_texts))

    assert_equal :dictionary, dict.tag_name
  end

  def test_tag_refs
    assert_equal 'definition', DictionaryOfTexts.tag_refs.only.name
    assert_equal 'word', DictionaryOfTexts.tag_refs.only.hash.key.name
    assert_equal 'meaning', DictionaryOfTexts.tag_refs.only.hash.value.name

    dict = DictionaryOfTexts.from_xml(fixture(:dictionary_of_texts))

    assert_equal 'definition', dict.tag_refs.only.name
    assert_equal 'word', dict.tag_refs.only.hash.key.name
    assert_equal 'meaning', dict.tag_refs.only.hash.value.name
  end
end