require "lib/roxml"
require "test/unit"
require "test/fixture_helper"
require "test/mocks/mocks"

class TestROXML < Test::Unit::TestCase
  include FixtureHelper
  
  # Test a simple mapping with no composition
  def test_valid_simple
    book = Book.parse(fixture(:book_valid))
    assert_equal("The PickAxe", book.title)
  end

  # Malformed XML parsing should throw REXML::ParseException
  def test_malformed
    begin
      book = Book.parse(fixture(:book_malformed))
      fail()
    rescue REXML::ParseException
    end
  end
  
  # Test XML object containing list of other XML objects (one-to-many)
  # In this case, book with contibutions
  def test_one_to_many_with_container
    expected_authors = ["David Thomas","Andrew Hunt","Chad Fowler"]
    book = BookWithContributions.parse(fixture(:book_with_contributions))
    assert_equal("Programming Ruby - 2nd Edition", book.title)
    book.contributions.each do |contributor|
      assert expected_authors.include?(contributor.name)
    end
  end
  
  # Test XML object containing 1-n other XML objects without container (one-to-many)
  # In this case, book with contibutions
  def test_one_to_many_without_container
    expected_contributors = ["David Thomas","Andrew Hunt","Chad Fowler"]
    book = BookWithContributors.parse(fixture(:book_with_contributors))
    assert_equal("Programming Ruby - 2nd Edition", book.title)
    book.contributors.each do |contributor|
      assert(expected_contributors.include?(contributor.name))
    end
  end  

  # Test XML object containing one other XML object (one-to-one)
  # In this case, book with publisher
  def test_one_to_one
    book = BookWithPublisher.parse(fixture(:book_with_publisher))
    assert_equal("Programming Ruby - 2nd Edition", book.title)
    assert_equal("Pragmatic Bookshelf", book.publisher.name)
  end
  
  # Test XML object containing type of self (self-reference)
  def test_self_reference
    book = BookPair.parse(fixture(:book_pair))
    assert_equal("Programming Ruby - 2nd Edition", book.title)
    assert_equal("Agile Web Development with Rails", book.book.title)    
  end
  
  # Test three-level composition (one-to-many-to-many)
  def test_one_to_many_to_many
    expected_contributors = ["David Thomas","Andrew Hunt","Chad Fowler", "David Heinemeier Hansson"]
    expected_books = ["Programming Ruby - 2nd Edition", "Agile Web Development with Rails"]
    library = Library.parse(fixture(:library))
    assert_equal("Ruby library", library.name)
    library.books.each do |book|
      assert expected_books.include?(book.title)
      book.contributions.each do |contributor|
        assert(expected_contributors.include?(contributor.name))
      end
    end
  end

  # Verify that an exception is thrown when two accessors have the same
  # name in a ROXML class.
  def test_duplicate_accessor
    begin
      klass = Class.new do
        include ROXML
        
        xml_attribute :id
        xml_text :id
      end   
      raise "Defining a class with multiple accessors with same name should fail."
    rescue
      # Ok we should fail.
    end
  end
end