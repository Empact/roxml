require_relative './../test_helper'

class TestDefinition < ActiveSupport::TestCase
  def assert_hash(opts, kvp)
    assert opts.hash?
    assert !opts.array?
    assert_equal kvp, {opts.hash.key.sought_type => opts.hash.key.name,
                       opts.hash.value.sought_type => opts.hash.value.name}
  end

  def test_empty_array_means_as_array_for_text
    opts = ROXML::Definition.new(:authors, :as => [])
    assert opts.array?
    assert_equal :text, opts.sought_type
  end

  def test_attr_in_array_means_as_array_for_attr
    opts = ROXML::Definition.new(:authors, :as => [], :from => :attr)
    assert opts.array?
    assert_equal :attr, opts.sought_type
  end

  def test_block_shorthand_in_array_means_array
    opts = ROXML::Definition.new(:intarray, :as => [Integer])
    assert opts.array?
    assert_equal :text, opts.sought_type
    assert_equal 1, opts.blocks.size
  end

  def test_required
    assert !ROXML::Definition.new(:author).required?
    assert ROXML::Definition.new(:author, :required => true).required?
    assert !ROXML::Definition.new(:author, :required => false).required?
  end

  def test_required_conflicts_with_else
    assert_raise ArgumentError do
      ROXML::Definition.new(:author, :required => true, :else => 'Johnny')
    end
    assert_nothing_raised do
      ROXML::Definition.new(:author, :required => false, :else => 'Johnny')
    end
  end

  def test_hash_of_attrs
    opts = ROXML::Definition.new(:attributes, :as => {:key => '@name', :value => '@value'})
    assert_hash(opts, :attr => 'name', :attr => 'value')
  end

  def test_hash_with_attr_key_and_text_val
    opts = ROXML::Definition.new(:attributes, :as => {:key => '@name',
                                         :value => :value})
    assert_hash(opts, :attr => 'name', :text => 'value')
  end

  def test_hash_with_string_class_for_type
    opts = ROXML::Definition.new(:attributes, :as => {:key => 'name',
                                         :value => 'value'})
    assert_hash(opts, :text => 'name', :text => 'value')
  end

  def test_hash_with_attr_key_and_content_val
    opts = ROXML::Definition.new(:attributes, :as => {:key => '@name',
                                         :value => :content})
    assert_hash(opts, :attr => 'name', :text => '.')
  end

  def test_hash_with_options
    opts = ROXML::Definition.new(:definitions, :as => {:key => '@dt', :value => '@dd'},
                           :in => :definitions, :from => 'definition')
    assert_hash(opts, :attr => 'dt', :attr => 'dd')
    assert_equal 'definition', opts.hash.wrapper
  end

  def test_no_block_shorthand_means_no_block
    assert ROXML::Definition.new(:count).blocks.empty?
  end

  def test_block_integer_shorthand
    assert_equal 3, ROXML::Definition.new(:count, :as => Integer).blocks.first['3']
  end

  def test_block_float_shorthand
    assert_equal 3.1, ROXML::Definition.new(:count, :as => Float).blocks.first['3.1']
  end

  def test_from_attr_is_supported
    opts = ROXML::Definition.new(:count, :from => :attr)
    assert_equal "count", opts.name
    assert_equal :attr, opts.sought_type
  end

  def test_from_at_name_is_supported
    opts = ROXML::Definition.new(:count, :from => "@COUNT")
    assert_equal "COUNT", opts.name
    assert_equal :attr, opts.sought_type
  end

  def test_multiple_shorthands_raises
    assert_raise ArgumentError do
      assert_deprecated do
        ROXML::Definition.new(:count, :as => [Float, Integer])
      end
    end
  end

  def test_stacked_blocks
    assert_equal 2, ROXML::Definition.new(:count, :as => Integer) {|val| val.to_i }.blocks.size
    assert_equal 2, ROXML::Definition.new(:count, :as => Float) {|val| val.object_id }.blocks.size
  end

  def test_block_shorthand_supports_bool
    assert_equal true, ROXML::Definition.new(:floatvalue, :as => :bool).blocks.first.call("1")
    assert_equal [true, false, nil], ROXML::Definition.new(:floatvalue, :as => :bool).blocks.first.call(["TrUe", "0", "328"])
  end

  def test_block_shorthand_supports_integer
    assert_equal nil, ROXML::Definition.new(:floatvalue, :as => Integer).blocks.first.call(" ")
    assert_equal 792, ROXML::Definition.new(:floatvalue, :as => Integer).blocks.first.call("792")
    assert_raise ArgumentError do
      ROXML::Definition.new(:floatvalue, :as => Integer).blocks.first.call("792.13")
    end
    assert_equal [792, 12, 328], ROXML::Definition.new(:floatvalue, :as => Integer).blocks.first.call(["792", "12", "328"])
  end

  def test_block_shorthand_supports_float
    assert_equal nil, ROXML::Definition.new(:floatvalue, :as => Float).blocks.first.call("  ")
    assert_equal 792.13, ROXML::Definition.new(:floatvalue, :as => Float).blocks.first.call("792.13")
    assert_equal 240.0, ROXML::Definition.new(:floatvalue, :as => Float).blocks.first.call("240")
    assert_equal [792.13, 240.0, 3.14], ROXML::Definition.new(:floatvalue, :as => Float).blocks.first.call(["792.13", "240", "3.14"])
  end

  def test_block_shorthand_supports_time
    assert_equal nil, ROXML::Definition.new(:floatvalue, :as => Time).blocks.first.call("  ")
    assert_equal 31, ROXML::Definition.new(:datevalue, :as => Time).blocks.first.call("12:31am").min
    assert_equal [31, 0, 59], ROXML::Definition.new(:datevalue, :as => Time).blocks.first.call(["12:31am", "3:00pm", "11:59pm"]).map(&:min)
  end

  def test_block_shorthand_supports_date
    assert_equal nil, ROXML::Definition.new(:floatvalue, :as => Date).blocks.first.call("  ")
    assert_equal "1970-09-03", ROXML::Definition.new(:datevalue, :as => Date).blocks.first.call("September 3rd, 1970").to_s
    assert_equal ["1970-09-03", "1776-07-04"], ROXML::Definition.new(:datevalue, :as => Date).blocks.first.call(["September 3rd, 1970", "1776-07-04"]).map(&:to_s)
  end

  def test_block_shorthand_supports_datetime
    assert_equal nil, ROXML::Definition.new(:floatvalue, :as => DateTime).blocks.first.call("  ")
    assert_equal "1970-09-03T12:05:00+00:00", ROXML::Definition.new(:datevalue, :as => DateTime).blocks.first.call("12:05pm, September 3rd, 1970").to_s
    assert_equal ["1970-09-03T12:05:00+00:00", "1700-05-22T15:00:00+00:00"], ROXML::Definition.new(:datevalue, :as => DateTime).blocks.first.call(["12:05pm, September 3rd, 1970", "3:00pm, May 22, 1700"]).map(&:to_s)
  end

  def test_name_explicit_indicates_whether_from_option_is_present
    assert_equal true, ROXML::Definition.new(:element, :from => 'somewhere').name_explicit?
    assert_equal false, ROXML::Definition.new(:element).name_explicit?
  end

  def test_xpath_in_is_formed_properly
    opts = ROXML::Definition.new(:manufacturer, :in => './')
    assert_equal "manufacturer", opts.name
    assert_equal "./", opts.wrapper
  end

  def test_cdata_is_specifiable
    assert ROXML::Definition.new(:manufacturer, :cdata => true).cdata?
  end

  def test_as_supports_generic_roxml_types
    assert_equal RoxmlObject, ROXML::Definition.new(:type, :as => RoxmlObject).sought_type
  end

  def test_as_supports_generic_roxml_types_in_arrays
    assert_equal RoxmlObject, ROXML::Definition.new(:types, :as => [RoxmlObject]).sought_type
  end

  def test_default_works
    opts = ROXML::Definition.new(:missing, :else => true)
    assert_equal true, opts.to_ref(RoxmlObject.new).value_in(ROXML::XML.parse_string('<xml></xml>'))
  end

  def test_default_works_for_arrays
    opts = ROXML::Definition.new(:missing, :as => [])
    assert_equal [], opts.to_ref(RoxmlObject.new).value_in(ROXML::XML.parse_string('<xml></xml>'))
  end

  def test_default_works_for_recursive_objects
    opts = ROXML::Definition.new(:missing, :as => RecursiveObject, :else => false)
    assert_equal false, opts.to_ref(RoxmlObject.new).value_in(ROXML::XML.parse_string('<xml></xml>'))
  end

  def test_content_is_accepted_as_from
    assert ROXML::Definition.new(:author, :from => :content).content?
    assert ROXML::Definition.new(:author, :from => '.').content?
  end

  def test_content_is_a_recognized_type
    opts = ROXML::Definition.new(:author, :from => :content)
    assert opts.content?
    assert_equal '.', opts.name
    assert_equal :text, opts.sought_type
  end

  def test_content_symbol_as_target_is_translated_to_string
    opts = ROXML::Definition.new(:content, :from => :attr)
    assert_equal 'content', opts.name
    assert_equal :attr, opts.sought_type
  end

  def test_attr_is_accepted_as_from
    assert_equal :attr, ROXML::Definition.new(:author, :from => :attr).sought_type
    assert_equal :attr, ROXML::Definition.new(:author, :from => '@author').sought_type
  end

  def test_attr_is_a_recognized_type
    opts = ROXML::Definition.new(:author, :from => :attr)
    assert_equal 'author', opts.name
    assert_equal :attr, opts.sought_type
  end
end

class RecursiveObject
  include ROXML

  xml_reader :next, :as => RecursiveObject, :else => true
end

class RoxmlObject
  include ROXML
end

class HashDefinitionTest < ActiveSupport::TestCase
  def test_content_detected_as_from
    opts = ROXML::Definition.new(:hash, :as => {:key => :content, :value => :name})
    assert_equal '.', opts.hash.key.name
    assert_equal :text, opts.hash.key.sought_type
  end
end