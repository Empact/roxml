require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestXMLText < Test::Unit::TestCase
  include FixtureHelper

  # Test book with text and attribute
  def test_book_author_text_attribute
    book = BookWithAuthorTextAttribute.parse(fixture(:book_text_with_attribute))
    assert_equal("primary",book.author.role)
    assert_equal("David Thomas",book.author.text)
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
    assert !library.books.empty?
    library.books.each do |book|
      assert expected_books.include?(book.title)
      book.contributions.each do |contributor|
        assert(expected_contributors.include?(contributor.name))
      end
    end
  end

  def test_xml_object_without_needed_from
    assert_equal [], UppercaseLibrary.parse(fixture(:library)).books
    assert_equal [], Library.parse(fixture(:library_uppercase)).books
  end

  def test_xml_object_with_needed_from
    assert Library.parse(fixture(:library)).books
    assert UppercaseLibrary.parse(fixture(:library_uppercase)).books
  end

  def test_xml_object_with_recursion
    p = PersonWithMother.parse(fixture(:person_with_mothers))
    assert_equal 'Ben Franklin', p.name
    assert_equal 'Abiah Folger', p.mother.name
    assert_equal 'Madeup Mother', p.mother.mother.name
    assert_equal nil, p.mother.mother.mother
  end

  def test_xml_object_with_guarded_recursion
    p = PersonWithGuardedMother.parse(fixture(:person_with_guarded_mothers))
    assert_equal 'Ben Franklin', p.name
    assert_equal 'Abiah Folger', p.mother.name
    assert_equal 'Madeup Mother', p.mother.mother.name
    assert_equal nil, p.mother.mother.mother
  end
end