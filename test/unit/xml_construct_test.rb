require File.join(File.dirname(__FILE__), '..', 'test_helper')

class MeasurementWithXmlConstruct
  include ROXML

  xml_reader :units, :from => :attr
  xml_reader :value, :from => :content

  xml_construct_without_deprecation :value, :units

  def initialize(value, units = 'pixels')
    @value = Float(value)
    @units = units.to_s
    if @units.starts_with? 'hundredths-'
      @value /= 100
      @units = @units.split('hundredths-')[1]
    end
  end

  def ==(other)
    other.units == @units && other.value == @value
  end
end

class BookWithDepthWithXmlConstruct
  include ROXML

  xml_reader :isbn, :from => '@ISBN'
  xml_reader :title
  xml_reader :description, :cdata => true
  xml_reader :author
  xml_reader :depth, MeasurementWithXmlConstruct
end

class InheritedBookWithDepthWithXmlConstruct < Book
  xml_reader :depth, MeasurementWithXmlConstruct
end

class TestXMLConstruct < Test::Unit::TestCase
  def test_is_deprecated
    assert_deprecated do
      MeasurementWithXmlConstruct.xml_construction_args
    end
  end

  def test_initialize_is_run
    m = MeasurementWithXmlConstruct.from_xml('<measurement units="hundredths-meters">1130</measurement>')
    assert_equal 11.3, m.value
    assert_equal 'meters', m.units
  end

  def test_initialize_is_run_for_nested_type
    b = BookWithDepthWithXmlConstruct.from_xml(fixture(:book_with_depth))
    assert_equal Measurement.new(11.3, 'meters'), b.depth
  end

  def test_initialize_is_run_for_nested_type_with_inheritance
    b = InheritedBookWithDepthWithXmlConstruct.from_xml(fixture(:book_with_depth))
    assert_equal Measurement.new(11.3, 'meters'), b.depth
  end

  def test_xml_name_uses_accessor_not_name
    assert_nothing_raised do
      Class.new do
        include ROXML

        xml_reader :bar, :from => '@Foo'
        xml_reader :foo, :text => 'Foo'
        xml_reader :baz, :from => '@Bar'

        xml_construct_without_deprecation :baz, :bar, :foo
        def initialize(baz, bar, foo)
        end
      end
    end
  end
end