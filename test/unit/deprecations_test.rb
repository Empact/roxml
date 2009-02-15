require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestDefinition < Test::Unit::TestCase
  def test_literal_as_array_is_deprecated
    assert_deprecated do
      assert ROXML::Definition.new(:authors, :as => :array).array?
    end
  end

  def test_no_block_shorthand_means_no_block
    assert_deprecated do
      assert ROXML::Definition.new(:count, :as => :intager).blocks.empty?
    end
    assert_deprecated do
      assert ROXML::Definition.new(:count, :as => :foat).blocks.empty?
    end
  end

  def test_symbol_shorthands_are_deprecated
    assert_deprecated do
      ROXML::Definition.new(:junk, :as => :integer)
    end
    assert_deprecated do
      ROXML::Definition.new(:junk, :as => :float)
    end
  end
  
  def test_as_cdata_is_deprecated
    assert_deprecated do
      assert ROXML::Definition.new(:manufacturer, :as => :cdata).cdata?
    end
    assert_deprecated do
      assert ROXML::Definition.new(:manufacturer, :as => [Integer, :cdata]).cdata?
    end
  end

  def test_content_is_a_recognized_type
    assert_deprecated do
      opts = ROXML::Definition.new(:author, :content)
      assert opts.content?
      assert_equal '.', opts.name
      assert_equal :text, opts.type
    end
  end

  def test_content_symbol_as_target_is_translated_to_string
    assert_deprecated do
      opts = ROXML::Definition.new(:content, :attr => :content)
      assert_equal 'content', opts.name
      assert_equal :attr, opts.type
    end
  end

  def test_attr_is_a_recognized_type
    assert_deprecated do
      opts = ROXML::Definition.new(:author, :attr)
      assert_equal 'author', opts.name
      assert_equal :attr, opts.type
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
      opts = ROXML::Definition.new(:name, :as => {:attrs => [:dt, :dd]})
      assert opts.hash?
    end
  end
end