require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestXMLInitialize < Test::Unit::TestCase
  def test_xml_construct_not_in_use
    assert Measurement.xml_construction_args_without_deprecation.empty?
  end

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
end