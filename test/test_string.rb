require 'lib/roxml/string'

class TestROXML < Test::Unit::TestCase
  def test_to_latin_is_accessible
    assert String.instance_methods.include?('to_latin')
  end
  
  def test_to_utf_is_accessible
    assert String.instance_methods.include?('to_utf')
  end
end