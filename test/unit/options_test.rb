require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestOptions < Test::Unit::TestCase
  def assert_hash(opts, kvp)
    assert opts.hash?
    assert !opts.array?
    assert_equal kvp, {opts.hash.key.type => opts.hash.key.name,
                       opts.hash.value.type => opts.hash.value.name}
  end

  def test_text_in_array_means_as_array_for_text
    opts = ROXML::Opts.new(:authors, [:text])
    assert opts.array?
    assert_equal :text, opts.type
  end

  def test_attr_in_array_means_as_array_for_attr
    opts = ROXML::Opts.new(:authors, [:attr])
    assert opts.array?
    assert_equal :attr, opts.type
  end

  def test_object_in_array_means_as_array_for_object
    opts = ROXML::Opts.new(:authors, [Hash])
    assert opts.array?
    assert_equal Hash, opts.type
  end

  def test_content_is_a_recognized_type
    assert ROXML::Opts.new(:author, :content).content?
  end

  def test_required
    assert !ROXML::Opts.new(:author, :content).required?
    assert ROXML::Opts.new(:author, :content, :required => true).required?
    assert !ROXML::Opts.new(:author, :content, :required => false).required?
  end

  def test_required_conflicts_with_else
    assert_raise ArgumentError do
      ROXML::Opts.new(:author, :content, :required => true, :else => 'Johnny')
    end
    assert_nothing_raised do
      ROXML::Opts.new(:author, :content, :required => false, :else => 'Johnny')
    end
  end

  def test_hash_of_attrs
    opts = ROXML::Opts.new(:attributes, {:attrs => [:name, :value]})
    assert_hash(opts, :attr => 'name', :attr => 'value')
  end

  def test_hash_with_attr_key_and_text_val
    opts = ROXML::Opts.new(:attributes, {:key => {:attr => :name},
                                         :value => :value})
    assert_hash(opts, :attr => 'name', :text => 'value')
  end

  def test_hash_with_string_class_for_type
    opts = ROXML::Opts.new(:attributes, {:key => {String => 'name'},
                                         :value => {String => 'value'}})
    assert_hash(opts, :text => 'name', :text => 'value')
  end

  def test_hash_with_attr_key_and_content_val
    opts = ROXML::Opts.new(:attributes, {:key => {:attr => :name},
                                         :value => :content})
    assert_hash(opts, :attr => 'name', :content => '')
  end

  def test_hash_with_options
    opts = ROXML::Opts.new(:definitions, {:attrs => [:dt, :dd]},
                           :in => :definitions)
    assert_hash(opts, :attr => 'dt', :attr => 'dd')
  end

  def test_no_block_shorthand_means_no_block
    assert ROXML::Opts.new(:count).blocks.empty?
    assert ROXML::Opts.new(:count, :as => :intager).blocks.empty?
    assert ROXML::Opts.new(:count, :as => :foat).blocks.empty?
  end

  def test_block_integer_shorthand
    assert_equal 3, ROXML::Opts.new(:count, :as => Integer).blocks.first['3']
  end

  def test_block_float_shorthand
    assert_equal 3.1, ROXML::Opts.new(:count, :as => Float).blocks.first['3.1']
  end

  def test_multiple_shorthands_raises
    assert_raise ArgumentError do
      ROXML::Opts.new(:count, :as => [Float, Integer])
    end
  end

  def test_stacked_blocks
    assert_equal 2, ROXML::Opts.new(:count, :as => Integer) {|val| val.to_i }.blocks.size
    assert_equal 2, ROXML::Opts.new(:count, :as => Float) {|val| val.object_id }.blocks.size
  end

  def test_symbol_shorthands_are_deprecated
    assert_deprecated do
      ROXML::Opts.new(:junk, :as => :integer)
    end
    assert_deprecated do
      ROXML::Opts.new(:junk, :as => :float)
    end
  end

  def test_block_shorthand_supports_bool
    assert_equal true, ROXML::Opts.new(:floatvalue, :as => :bool).blocks.first.call("1")
    assert_equal [true, false, nil], ROXML::Opts.new(:floatvalue, :as => :bool).blocks.first.call(["TrUe", "0", "328"])
  end

  def test_block_shorthand_supports_integer
    assert_equal nil, ROXML::Opts.new(:floatvalue, :as => Integer).blocks.first.call(" ")
    assert_equal 792, ROXML::Opts.new(:floatvalue, :as => Integer).blocks.first.call("792")
    assert_raise ArgumentError do
      ROXML::Opts.new(:floatvalue, :as => Integer).blocks.first.call("792.13")
    end
    assert_equal [792, 12, 328], ROXML::Opts.new(:floatvalue, :as => Integer).blocks.first.call(["792", "12", "328"])
  end

  def test_block_shorthand_supports_float
    assert_equal nil, ROXML::Opts.new(:floatvalue, :as => Float).blocks.first.call("  ")
    assert_equal 792.13, ROXML::Opts.new(:floatvalue, :as => Float).blocks.first.call("792.13")
    assert_equal 240.0, ROXML::Opts.new(:floatvalue, :as => Float).blocks.first.call("240")
    assert_equal [792.13, 240.0, 3.14], ROXML::Opts.new(:floatvalue, :as => Float).blocks.first.call(["792.13", "240", "3.14"])
  end

  def test_block_shorthand_supports_time
    assert_equal nil, ROXML::Opts.new(:floatvalue, :as => Time).blocks.first.call("  ")
    assert_equal 31, ROXML::Opts.new(:datevalue, :as => Time).blocks.first.call("12:31am").min
    assert_equal [31, 0, 59], ROXML::Opts.new(:datevalue, :as => Time).blocks.first.call(["12:31am", "3:00pm", "11:59pm"]).map(&:min)
  end

  def test_block_shorthand_supports_date
    assert_equal nil, ROXML::Opts.new(:floatvalue, :as => Date).blocks.first.call("  ")
    assert_equal "1970-09-03", ROXML::Opts.new(:datevalue, :as => Date).blocks.first.call("September 3rd, 1970").to_s
    assert_equal ["1970-09-03", "1776-07-04"], ROXML::Opts.new(:datevalue, :as => Date).blocks.first.call(["September 3rd, 1970", "1776-07-04"]).map(&:to_s)
  end

  def test_block_shorthand_supports_datetime
    assert_equal nil, ROXML::Opts.new(:floatvalue, :as => DateTime).blocks.first.call("  ")
    assert_equal "1970-09-03T12:05:00+00:00", ROXML::Opts.new(:datevalue, :as => DateTime).blocks.first.call("12:05pm, September 3rd, 1970").to_s
    assert_equal ["1970-09-03T12:05:00+00:00", "1700-05-22T15:00:00+00:00"], ROXML::Opts.new(:datevalue, :as => DateTime).blocks.first.call(["12:05pm, September 3rd, 1970", "3:00pm, May 22, 1700"]).map(&:to_s)
  end
end