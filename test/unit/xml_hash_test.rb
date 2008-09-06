require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestXMLHash < Test::Unit::TestCase
  def setup
    @contents = {'quaquaversally' => 'adjective: (of a geological formation) sloping downward from the center in all directions.',
                 'tergiversate' => 'To use evasions or ambiguities; equivocate.'}
  end

  def test_attrs_hash
    dict = DictionaryOfAttrs.parse(fixture(:dictionary_of_attrs))
    assert_equal Hash, dict.class
    assert_equal @contents, dict
  end

  def test_text_hash
    dict = DictionaryOfTexts.parse(fixture(:dictionary_of_texts))
    assert_equal Hash, dict.class
    assert_equal @contents, dict
  end

  def test_mixed_text_content_hash
    dict = DictionaryOfMixeds.parse(fixture(:dictionary_of_mixeds))
    assert_equal Hash, dict.class
    assert_equal @contents, dict
  end
end