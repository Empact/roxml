require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestInheritance < Test::Unit::TestCase
  def setup
    @b = InheritedBookWithDepth.from_xml(fixture(:book_with_depth))
  end

  def test_inherited_object_should_include_parents_attributes
    assert_equal '0201710897', @b.isbn
    assert_equal 'The PickAxe', @b.title
    assert_equal 'Probably the best Ruby book out there', @b.description
    assert_equal 'David Thomas, Andrew Hunt, Dave Thomas', @b.author
    assert_equal 0, @b.pages
  end

  def test_inherited_object_should_include_its_own_attributes
    assert_equal '11.3 meters', @b.depth.to_s
  end
end