require_relative './../test_helper'
require 'minitest/autorun'
require 'active_support/testing/deprecation'

class TestDeprecation < Minitest::Test
  include ActiveSupport::Testing::Deprecation

  def test_as_array_not_deprecated
    assert_not_deprecated ActiveSupport::Deprecation.new do
      opts = ROXML::Definition.new(:name, :as => [])
      assert_equal :text, opts.sought_type
      assert opts.array?
    end
  end

  def test_as_hash_not_deprecated
    assert_not_deprecated ActiveSupport::Deprecation.new do
      opts = ROXML::Definition.new(:name, :as => {:key => '@dt', :value => '@dd'})
      assert opts.hash_definition?
    end
  end

  def test_as_object_with_from_xml_not_deprecated
    assert_not_deprecated ActiveSupport::Deprecation.new do
      ROXML::Definition.new(:name, :as => OctalInteger)
    end
  end

  def test_as_hash_of_as_type_not_deprecated
    assert_not_deprecated ActiveSupport::Deprecation.new do
      opts = ROXML::Definition.new(:name, :as => {:key => :name, :value => {:from => 'value', :as => OctalInteger}})
      assert opts.hash_definition?
      assert_equal OctalInteger, opts.hash_definition.value.sought_type
      assert_equal 'value', opts.hash_definition.value.name
    end
  end

  def test_multiple_shorthands_raises
    assert_raises ArgumentError do
      ROXML::Definition.new(:count, :as => [Float, Integer])
    end
  end
end
