require File.join(File.dirname(__FILE__), '..', 'test_helper')

class NestedObjectXmlNameBug < Test::Unit::TestCase
  def test_that_nested_object_uses_object_xml_name
    p "Nested ROXML objects should use nested object's xml_name when to_xml is called"
    
    parent = NestedParent.new
    parent.nested_child = NestedChild.new
    
    xml = "<nestedparent>\n  <child/>\n</nestedparent>"
    
    assert_equal xml, parent.to_xml.to_s
  end
end