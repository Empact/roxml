require_relative './../test_helper'

class TestXMLAttribute < ActiveSupport::TestCase
  def test_attr_from
    # :attr => *
    book = Book.from_xml(fixture(:book_text_with_attribute))
    assert_equal '0201710897', book.isbn

    # :attr, :from => *
    book = BookWithAttrFrom.from_xml(fixture(:book_text_with_attribute))
    assert_equal '0201710897', book.isbn
  end

  def test_mutable_attr
    book = Book.from_xml(fixture(:book_text_with_attribute))
    assert book.respond_to?(:'isbn=')
  end

  def test_default_initialization
    person = PersonWithMotherOrMissing.from_xml(fixture(:nameless_ageless_youth))
    assert_equal 21, person.age
  end

  def test_recursive_with_default_initialization
    p = PersonWithMotherOrMissing.from_xml(fixture(:person_with_mothers))
    assert_equal 21, p.mother.mother.mother.age
  end

  def test_no_name_clashes
    n = NodeWithAttrNameConflicts.from_xml(fixture(:node_with_attr_name_conflicts))
    assert_equal "Just junk... really", n.content
    assert_equal "Cartwheel", n.name
  end

  def test_wrapped_attr_accessible
    b = BookWithWrappedAttr.from_xml(fixture(:book_with_wrapped_attr))
    assert_equal "0974514055", b.isbn
  end
end