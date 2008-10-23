require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestXMLBlocks < Test::Unit::TestCase
  def test_block_is_applied
    muffins = Muffins.from_xml(fixture(:muffins))

    assert muffins.count > 0
    assert_equal 0, muffins.count % 13
  end
end