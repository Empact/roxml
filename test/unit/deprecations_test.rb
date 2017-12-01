require_relative './../test_helper'
require 'minitest/autorun'
require 'active_support/testing/deprecation'

class TestDeprecation < Minitest::Test
  include ActiveSupport::Testing::Deprecation

  def test_as_array_not_deprecated
    assert_not_deprecated do
      opts = ROXML::Definition.new(:name, :as => [])
      assert_equal :text, opts.sought_type
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

  def test_as_hash_of_as_type_not_deprecated
    assert_not_deprecated do
      opts = ROXML::Definition.new(:name, :as => {:key => :name, :value => {:from => 'value', :as => OctalInteger}})
      assert opts.hash?
      assert_equal OctalInteger, opts.hash.value.sought_type
      assert_equal 'value', opts.hash.value.name
    end
  end

  def test_multiple_shorthands_raises
    assert_raises ArgumentError do
      assert_deprecated do
        ROXML::Definition.new(:count, :as => [Float, Integer])
      end
    end
  end
end
