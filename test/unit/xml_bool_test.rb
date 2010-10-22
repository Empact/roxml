require_relative './../test_helper'

PROC_TRUE = proc {|val| val ? 'TRUE' : 'FALSE'}
PROC_True = proc {|val| val ? 'True' : 'False'}
PROC_true = proc {|val| val.to_s}
PROC_1    = proc {|val| val ? 1 : 0}

class XmlBool
  include ROXML

  xml_name 'xml_bool'
  xml_reader :true_from_TRUE?, :to_xml => PROC_TRUE
  xml_reader :false_from_FALSE?, :from => 'text_for_FALSE', :to_xml => PROC_TRUE
  xml_reader :true_from_one?, :from => '@attr_for_one', :to_xml => PROC_1
  xml_reader :false_from_zero?, :from => 'text_for_zero', :in => 'container', :to_xml => PROC_1
  xml_reader :true_from_True?, :from => '@attr_for_True', :in => 'container', :to_xml => PROC_True
  xml_reader :false_from_False?, :from => 'false_from_cdata_False', :cdata => true, :to_xml => PROC_True
  xml_reader :true_from_true?, :to_xml => PROC_true
  xml_reader :false_from_false?, :to_xml => PROC_true
  xml_reader :missing?
end

class XmlBoolRequired
  include ROXML

  xml_reader :required?, :required => true
end

class XmlBoolUnexpected
  include ROXML

  xml_reader :unexpected?
end

class XmlBoolUnexpectedWithBlock
  include ROXML

  xml_reader :unexpected? do |val|
    val
  end
end

BOOL_XML = %{
  <xml_bool attr_for_one="1">
    <true_from_TRUE>TRUE</true_from_TRUE>
    <text_for_FALSE>FALSE</text_for_FALSE>
    <container attr_for_True="True">
      <text_for_zero>0</text_for_zero>
    </container>
    <false_from_cdata_False><![CDATA[False]]></false_from_cdata_False>
    <true_from_true>true</true_from_true>
    <false_from_false>false</false_from_false>
  </xml_bool>
}
PRESENT = %{
  <xml_bool_required>
    <required>true</required>
  </xml_bool_required>
}
ABSENT = %{
  <xml_bool_required>
  </xml_bool_required>
}
UNEXPECTED_VALUE_XML = %{
  <xml_bool_unexpected>
    <unexpected>Unexpected Value</unexpected>
  </xml_bool_unexpected>
}


class TestXMLBool < ActiveSupport::TestCase
  def test_bool_results_for_various_inputs
    x = XmlBool.from_xml(BOOL_XML)
    assert_equal true, x.true_from_TRUE?
    assert_equal false, x.false_from_FALSE?
    assert_equal true, x.true_from_one?
    assert_equal false, x.false_from_zero?
    assert_equal true, x.true_from_True?
    assert_equal false, x.false_from_False?
    assert_equal true, x.true_from_true?
    assert_equal false, x.false_from_false?
  end

  def test_missing_results_in_nil
    x = XmlBool.from_xml(BOOL_XML)
    assert_equal nil, x.missing?
  end

  def test_unexpected_value_results_in_nil
    x = XmlBoolUnexpected.from_xml(UNEXPECTED_VALUE_XML)
    assert_equal nil, x.unexpected?
  end

  def test_block_recieves_unexpected_value_rather_than_nil
    x = XmlBoolUnexpectedWithBlock.from_xml(UNEXPECTED_VALUE_XML)
    assert_equal "Unexpected Value", x.unexpected?
  end

  def test_required_raises_on_missing
    assert_nothing_raised do
      XmlBoolRequired.from_xml(PRESENT)
    end

    assert_raise ROXML::RequiredElementMissing do
      XmlBoolRequired.from_xml(ABSENT)
    end
  end

  def test_writable_references_properly_handle_punctuation
    klass = Class.new do
      include ROXML
      xml_accessor :punctuation?
    end

    instance = klass.from_xml("<xml><punctuation>True</punctuation></xml>")
    assert_equal true, instance.punctuation?
    instance.punctuation = false
    assert_equal false, instance.punctuation?
  end

  to_xml_test XmlBool => BOOL_XML
end