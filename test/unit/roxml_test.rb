require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestROXML < Test::Unit::TestCase
  # Malformed XML parsing should throw REXML::ParseException
  def test_malformed
    ROXML::XML::Parser.register_error_handler {|err| }
    assert_raise ROXML::XML::Parser::ParseError do
      book = Book.from_xml(fixture(:book_malformed))
    end
  end

  # Verify that an exception is thrown when two accessors have the same
  # name in a ROXML class.
  def test_duplicate_accessor
    assert_raise RuntimeError do
      Class.new do
        include ROXML

        xml_reader :id
        xml_accessor :id
      end
    end
  end

  def test_tag_refs_is_deprecated
    assert_deprecated do
      Class.new do
        include ROXML
      end.tag_refs
    end
  end

  def test_from_xml_should_support_pathnames
    book = BookWithContributors.from_xml(Pathname.new(fixture_path(:book_with_contributors)))
    expected_contributors = ["David Thomas","Andrew Hunt","Chad Fowler"]
    assert_equal("Programming Ruby - 2nd Edition", book.title)
    book.contributors.each do |contributor|
      assert(expected_contributors.include?(contributor.name))
    end
  end

  def test_from_xml_should_support_uris
    uri = URI.parse("file://#{File.expand_path(File.expand_path(fixture_path(:book_with_contributors)))}")
    book = BookWithContributors.from_xml(uri)
    expected_contributors = ["David Thomas","Andrew Hunt","Chad Fowler"]
    assert_equal("Programming Ruby - 2nd Edition", book.title)
    book.contributors.each do |contributor|
      assert(expected_contributors.include?(contributor.name))
    end
  end

  def test_from_xml_should_support_files
    book = BookWithContributors.from_xml(File.new(fixture_path(:book_with_contributors)))
    expected_contributors = ["David Thomas","Andrew Hunt","Chad Fowler"]
    assert_equal("Programming Ruby - 2nd Edition", book.title)
    book.contributors.each do |contributor|
      assert(expected_contributors.include?(contributor.name))
    end
  end
end
