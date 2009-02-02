require File.join(File.dirname(__FILE__), '..', 'test_helper')

class DescriptionReadonly
  include ROXML

  xml_reader :writable, :from => :content
  xml_reader :readonly, :from => :content, :frozen => true
end

class BookWithContributionsReadonly
  include ROXML

  xml_name :book
  xml_reader :isbn, :from => :attr, :frozen => true
  xml_reader :title, :frozen => true
  xml_reader :description, DescriptionReadonly, :frozen => true
  xml_reader :contributions, [Contributor], :from => 'contributor', :in => "contributions", :frozen => true
end

class DictionaryOfGuardedNamesReadonly
  include ROXML

  xml_name :dictionary
  xml_reader :definitions, {:key => :name,
                            :value => :content}, :in => :definitions, :frozen => true
end

class TestFreeze < Test::Unit::TestCase
  def setup
    @writable = BookWithContributions.from_xml(fixture(:book_with_contributions))
    @readonly = BookWithContributionsReadonly.from_xml(fixture(:book_with_contributions))
    @dict_readonly = DictionaryOfGuardedNamesReadonly.from_xml(fixture(:dictionary_of_guarded_names))
  end

  def test_attr_is_unmodifiable
    assert !@writable.isbn.frozen?
    assert @readonly.isbn.frozen?
  end

  def test_text_is_unmodifiable
    assert !@writable.title.frozen?
    assert @readonly.title.frozen?
  end

  def test_objects_are_unmodifiable
    assert @readonly.description.frozen?
  end

  def test_indirect_attrs_can_be_frozen_or_not
    assert @readonly.description.readonly.frozen?
    assert !@readonly.description.writable.frozen?
  end

  def test_arrays_are_unmodifiable
    assert !@writable.contributions.frozen?
    assert @readonly.contributions.frozen?
  end

  def test_array_elements_are_unmodifiable
    assert @readonly.contributions.all?(&:frozen?)
  end

  def test_hashes_are_unmodifiable
    assert @dict_readonly.definitions.frozen?
  end

  def test_hash_keys_and_values_are_unmodifiable
    assert @dict_readonly.definitions.keys.all?(&:frozen?)
    assert @dict_readonly.definitions.values.all?(&:frozen?)
  end
end