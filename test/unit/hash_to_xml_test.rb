require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestHashToXml < Test::Unit::TestCase
  to_xml_test :dictionary_of_attrs
end