require_relative './../test_helper'

class ArrayWithBlockShorthand
  include ROXML

  xml_reader :array, :as => [Integer], :from => 'number'
end

class ArrayWithBlock
  include ROXML

  xml_reader :array, :as => [], :from => 'number' do |arr|
    arr.map(&:to_i).reverse
  end
end

class TestXMLBlocks < ActiveSupport::TestCase
  def test_block_is_applied
    muffins = Muffins.from_xml(fixture(:muffins))

    assert muffins.count > 0
    assert_equal 0, muffins.count % 13
  end

  def test_block_is_applied_to_hash
    numerology = Numerology.from_xml(fixture(:numerology))

    assert !numerology.predictions.keys.empty?
    assert numerology.predictions.keys.all? {|k| k.is_a? Integer }
    assert numerology.predictions.values.all? {|k| k.is_a? String }
  end

  def test_stacked_blocks_are_applied
    muffins = MuffinsWithStackedBlocks.from_xml(fixture(:muffins))

    assert muffins.count > 0
    assert_equal 0, muffins.count % 13
  end

  def test_block_shorthand_applied_properly_to_array
    obj = ArrayWithBlockShorthand.from_xml(%{
      <array_with_block_shorthand>
        <number>1</number>
        <number>2</number>
        <number>3</number>
      </array_with_block_shorthand>
    })

    assert_equal [1, 2, 3], obj.array
  end

  def test_block_applied_properly_to_array
    obj = ArrayWithBlock.from_xml(%{
      <array_with_block>
        <number>1</number>
        <number>2</number>
        <number>3</number>
      </array_with_block>
    })

    assert_equal [3, 2, 1], obj.array
  end

  def test_block_shorthand_applied_properly_to_empty_array
    obj = ArrayWithBlockShorthand.from_xml(%{
      <array_with_block_shorthand>
      </array_with_block_shorthand>
    })

    assert_equal [], obj.array
  end

  def test_block_applied_properly_to_empty_array
    obj = ArrayWithBlock.from_xml(%{
      <array_with_block>
      </array_with_block>
    })

    assert_equal [], obj.array
  end
end