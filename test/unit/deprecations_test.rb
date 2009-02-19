require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestDefinition < Test::Unit::TestCase
  def test_no_block_shorthand_means_no_block
    assert_deprecated do
      assert ROXML::Definition.new(:count, :as => :intager).blocks.empty?
    end
    assert_deprecated do
      assert ROXML::Definition.new(:count, :as => :foat).blocks.empty?
    end
  end

  def test_as_array_not_deprecated
    assert_not_deprecated do
      opts = ROXML::Definition.new(:name, :as => [])
      assert_equal :text, opts.type
      assert opts.array?
    end
  end

  def test_as_hash_not_deprecated
    assert_not_deprecated do
      opts = ROXML::Definition.new(:name, :as => {:key => '@dt', :value => '@dd'})
      assert opts.hash?
    end
  end

  def test_as_object_with_from_xml_not_deprecated
    assert_not_deprecated do
      ROXML::Definition.new(:name, :as => OctalInteger)
    end
  end
end