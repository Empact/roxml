require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestXMLAttribute < Test::Unit::TestCase
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

  def test_xml_name_uses_accessor_not_name
    assert_nothing_raised do
      Class.new do
        include ROXML

        xml_reader :bar, :attr => 'Foo'
        xml_reader :foo, :text => 'Foo'
        xml_reader :baz, :attr => 'Bar'

        xml_construct :baz, :bar, :foo
        def initialize(baz, bar, foo)
        end
      end
    end
  end
end