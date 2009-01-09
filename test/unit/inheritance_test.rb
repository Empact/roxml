require File.join(File.dirname(__FILE__), '..', 'test_helper')

class InheritedBookWithDepth < Book
  xml_reader :depth, Measurement
end

class TestInheritance < Test::Unit::TestCase
  def setup
    @book_xml = %{
      <book ISBN="0201710897">
        <title>The PickAxe</title>
        <description><![CDATA[Probably the best Ruby book out there]]></description>
        <author>David Thomas, Andrew Hunt, Dave Thomas</author>
        <depth units="hundredths-meters">1130</depth>
        <publisher>Pragmattic Programmers</publisher>
      </book>
    }

    @b = InheritedBookWithDepth.from_xml(@book_xml)
  end

  def test_it_should_include_parents_attributes
    assert_equal '0201710897', @b.isbn
    assert_equal 'The PickAxe', @b.title
    assert_equal 'Probably the best Ruby book out there', @b.description
    assert_equal 'David Thomas, Andrew Hunt, Dave Thomas', @b.author
    assert_equal 0, @b.pages
  end

  def test_it_should_include_its_own_attributes
    assert_equal '11.3 meters', @b.depth.to_s
  end

  def test_it_should_include_parent_attributes_added_after_the_childs_definition
    Book.class_eval do
      xml_reader :publisher, :require => true
    end

    book = InheritedBookWithDepth.from_xml(@book_xml)
    assert_equal "Pragmattic Programmers", book.publisher
  end
end