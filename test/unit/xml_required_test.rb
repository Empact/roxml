require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestXMLRequired < Test::Unit::TestCase
  def setup
    @full_book = <<BOOK
  <book ISBN="1234">
    <title>This &amp; that</title>
    <contributor_array>
      <contributor role="Author">
        <name>Johnny</name>
      </contributor>
    </contributor_array>
    <contributor_hash>
      <contributor role="Author" name="Johnny" />
    </contributor_hash>
  </book>
BOOK

    @book_missing_attr = <<BOOK
  <book>
    <title>This &amp; that</title>
    <contributor_array>
      <contributor role="Author">
        <name>Johnny</name>
      </contributor>
    </contributor_array>
    <contributor_hash>
      <contributor role="Author" name="Johnny" />
    </contributor_hash>
  </book>
BOOK

    @book_missing_text = <<BOOK
  <book ISBN="1234">
    <contributor_array>
      <contributor role="Author">
        <name>Johnny</name>
      </contributor>
    </contributor_array>
    <contributor_hash>
      <contributor role="Author" name="Johnny" />
    </contributor_hash>
  </book>
BOOK

    @book_missing_array = <<BOOK
  <book ISBN="1234">
    <title>This &amp; that</title>
    <contributor_hash>
      <contributor role="Author" name="Johnny" />
    </contributor_hash>
  </book>
BOOK

    @book_missing_hash = <<BOOK
  <book ISBN="1234">
    <title>This &amp; that</title>
    <contributor_array>
      <contributor role="Author">
        <name>Johnny</name>
      </contributor>
    </contributor_array>
  </book>
BOOK
  end

  def test_required_passes_on_prescence
    BookWithRequired.parse(@full_book)
  end

  def test_required_throws_on_attr_absence
    assert_raise ROXML::RequiredElementMissing do
      BookWithRequired.parse(@book_missing_attr)    end
  end

  def test_required_throws_on_text_absence
    assert_raise ROXML::RequiredElementMissing do
      BookWithRequired.parse(@book_missing_text)
    end
  end

  def test_required_throws_on_array_absence
    assert_raise ROXML::RequiredElementMissing do
      BookWithRequired.parse(@book_missing_array)
    end
  end

  def test_required_throws_on_hash_absence
    assert_raise ROXML::RequiredElementMissing do
      BookWithRequired.parse(@book_missing_hash)
    end
  end
end