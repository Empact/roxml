require_relative './../test_helper'

class InheritedBookWithDepth < Book
  xml_reader :depth, :as => Measurement
end

class BookWithXmlInitialize < BookWithDepth
  attr_reader :created_at, :creator

  def initialize(created_at, creator = "Unknown")
    @created_at = created_at
    @creator = creator
  end
end

class TestXMLInitialize < ActiveSupport::TestCase
  def test_initialize_is_run
    m = Measurement.from_xml('<measurement units="hundredths-meters">1130</measurement>')
    assert_equal 11.3, m.value
    assert_equal 'meters', m.units
  end

  def test_initialize_is_run_for_nested_type
    b = BookWithDepth.from_xml(fixture(:book_with_depth))
    assert_equal Measurement.new(11.3, 'meters'), b.depth
  end

  def test_initialize_is_run_for_nested_type_with_inheritance
    b = InheritedBookWithDepth.from_xml(fixture(:book_with_depth))
    assert_equal Measurement.new(11.3, 'meters'), b.depth
  end

  def test_initialize_fails_on_missing_required_arg
    assert_raise ArgumentError do
      BookWithXmlInitialize.from_xml(fixture(:book_with_depth))
    end
  end

  def test_initialize_with_extra_args
    now = Time.now
    b = BookWithXmlInitialize.from_xml(fixture(:book_with_depth), now)
    assert_equal now, b.created_at
    assert_equal "Unknown", b.creator

    b = BookWithXmlInitialize.from_xml(fixture(:book_with_depth), Time.now, "Joe Librarian")
    assert now < b.created_at
    assert_equal "Joe Librarian", b.creator
  end
end