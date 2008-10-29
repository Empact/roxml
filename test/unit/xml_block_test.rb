require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestXMLBlocks < Test::Unit::TestCase
  def test_block_is_applied
    muffins = Muffins.from_xml(fixture(:muffins))

    assert muffins.count > 0
    assert_equal 0, muffins.count % 13
  end

  def test_block_is_applied_to_hash
    numerology = Numerology.from_xml(fixture(:numerology))

    assert !numerology.predictions.keys.empty?
    assert numerology.predictions.keys.all? {|k| k.is_a? Integer }
  end

  def test_stacked_blocks_are_applied
    muffins = MuffinsWithStackedBlocks.from_xml(fixture(:muffins))

    assert muffins.count > 0
    assert_equal 0, muffins.count % 13
  end
end