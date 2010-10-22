require_relative './../test_helper'

class TestDeprecation < ActiveSupport::TestCase
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
end