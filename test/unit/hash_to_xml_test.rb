require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestHashToXml < Test::Unit::TestCase
  def test_dictionary_of_attrs
    name = :dictionary_of_attrs
    dict = DictionaryOfAttrs.parse(fixture(name))
    assert_equal xml_fixture(name), dict.to_xml
  end
end