require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestHashToXml < Test::Unit::TestCase
  to_xml_test :dictionary_of_attrs, :dictionary_of_mixeds, :dictionary_of_texts
end