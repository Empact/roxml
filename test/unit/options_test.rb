require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestOptions < Test::Unit::TestCase
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

  def test_hash_of_attrs
    opts = ROXML::Opts.new(:attributes, {:attrs => [:name, :value]})
    assert opts.hash?
    assert !opts.array?
    assert_equal [ROXML::XMLAttributeRef, ROXML::XMLAttributeRef], opts.hash.types
    assert_equal ['name', 'value'], opts.hash.names
  end

  def test_hash_with_attr_key_and_text_val
    opts = ROXML::Opts.new(:attributes, {:key => {:attr => :name},
                                         :value => :value})
    assert opts.hash?
    assert !opts.array?
    assert_equal [ROXML::XMLAttributeRef, ROXML::XMLTextRef], opts.hash.types
    assert_equal ['name', 'value'], opts.hash.names
  end

  def test_hash_with_attr_key_and_text_content_val
    opts = ROXML::Opts.new(:attributes, {:key => {:attr => :name},
                                         :value => :text_content})
    assert opts.hash?
    assert !opts.array?
    assert opts.hash.value.text_content
    assert_equal [ROXML::XMLAttributeRef, ROXML::XMLTextRef], opts.hash.types
    assert_equal ['name', ''], opts.hash.names
  end

  def test_hash_with_options
    opts = ROXML::Opts.new(:definitions, {:attrs => [:dt, :dd]},
                           :in => :definitions)

    assert opts.hash?
    assert !opts.array?
    assert_equal [ROXML::XMLAttributeRef, ROXML::XMLAttributeRef], opts.hash.types
    assert_equal ['dt', 'dd'], opts.hash.names
  end
end