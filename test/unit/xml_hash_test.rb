require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestXMLHash < Test::Unit::TestCase
  def setup
    @contents = {'quaquaversally' => 'adjective: (of a geological formation) sloping downward from the center in all directions.',
                 'tergiversate' => 'To use evasions or ambiguities; equivocate.'}
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
end