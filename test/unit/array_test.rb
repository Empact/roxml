require File.join(File.dirname(__FILE__), '..', 'test_helper')

BOOK_WITH_CONTRIBUTORS = %{
  <book isbn="0974514055">
    <contributors>
      <contributor role="author"><name>David Thomas</name></contributor>
      <contributor role="supporting author"><name>Andrew Hunt</name></contributor>
      <contributor role="supporting author"><name>Chad Fowler</name></contributor>
    </contributors>
  </book>
}

class TestXmlArray < Test::Unit::TestCase
  def test_as_array_with_auto_guard
    assert_equal ["David Thomas","Andrew Hunt","Chad Fowler"].sort,
                 BookWithContributors.from_xml(BOOK_WITH_CONTRIBUTORS).contributors.map(&:name).sort
  end
end