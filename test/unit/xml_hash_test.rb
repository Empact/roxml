require_relative './../test_helper'

class BookWithContributorHash
  include ROXML

  xml_reader :contributors, :as => {:key => '@role',
                             :value => 'name'}
end

class TestXMLHash < ActiveSupport::TestCase
  def setup
    @contents = {'quaquaversally' => 'adjective: (of a geological formation) sloping downward from the center in all directions.',
                 'tergiversate' => 'To use evasions or ambiguities; equivocate.'}
  end

  def test_hash_preserves_data
    b = BookWithContributorHash.from_xml(%{
      <book isbn="0974514055">
        <contributor role="author"><name>David Thomas</name></contributor>
        <contributor role="supporting author"><name>Andrew Hunt</name></contributor>
        <contributor role="supporting author"><name>Chad Fowler</name></contributor>
      </book>
    })
    assert_equal({'author' => 'David Thomas', 'supporting author' => ['Andrew Hunt', 'Chad Fowler']},
      b.contributors)
  end

  def test_hash_with_object_key_fails
    assert_raise ArgumentError do
      Class.new do
        include ROXML

        xml_reader :object_key_to_text, :as => {:key => BookWithContributorHash,
                                         :value => 'text_node'}
      end
    end
  end

  def test_hash_with_object_value_fails
    assert_raise ArgumentError do
      Class.new do
        include ROXML

        xml_reader :key_to_object_value, :as => {:key => '@text_node',
                                          :value => BookWithContributorHash}
      end
    end
  end

  def test_attrs_hash
    dict = DictionaryOfAttrs.from_xml(fixture(:dictionary_of_attrs))
    assert_equal Hash, dict.definitions.class
    assert_equal @contents, dict.definitions
  end

  def test_text_hash
    dict = DictionaryOfTexts.from_xml(fixture(:dictionary_of_texts))
    assert_equal Hash, dict.definitions.class
    assert_equal @contents, dict.definitions
  end

  def test_mixed_content_hash
    dict = DictionaryOfMixeds.from_xml(fixture(:dictionary_of_mixeds))
    assert_equal Hash, dict.definitions.class
    assert_equal @contents, dict.definitions
  end

  def test_name_hash
    dict = DictionaryOfNames.from_xml(fixture(:dictionary_of_names))
    assert_equal Hash, dict.definitions.class
    assert_equal @contents, dict.definitions
  end

  def test_guarded_name_hash
    dict = DictionaryOfGuardedNames.from_xml(fixture(:dictionary_of_guarded_names))
    assert_equal Hash, dict.definitions.class
    assert_equal @contents, dict.definitions
  end

  def test_text_name_clashes
    dict = DictionaryOfNameClashes.from_xml(fixture(:dictionary_of_name_clashes))
    assert_equal Hash, dict.definitions.class
    assert_equal @contents, dict.definitions
  end

  def test_attr_name_clashes
    dict = DictionaryOfAttrNameClashes.from_xml(fixture(:dictionary_of_attr_name_clashes))
    assert_equal Hash, dict.definitions.class
    assert_equal @contents, dict.definitions
  end

  def test_it_should_gracefully_handle_empty_hash
    dict = Class.new do
      include ROXML

      xml_reader :missing_hash, :as => {:key => :name, :value => :content}, :in => 'EmptyDictionary'
    end

    assert_equal({}, dict.from_xml(%{
      <dict>
        <EmptyDictionary>
        </EmptyDictionary>
      </dict>
    }).missing_hash)
  end

  def test_as_hash_of_as_type_not_deprecated
    assert_not_deprecated do
      opts = ROXML::Definition.new(:name, :as => {:key => :name, :value => {:from => 'value', :as => OctalInteger}})
      assert opts.hash?
      assert_equal OctalInteger, opts.hash.value.sought_type
      assert_equal 'value', opts.hash.value.name
    end
  end
end