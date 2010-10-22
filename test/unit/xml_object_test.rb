# encoding: utf-8
require_relative './../test_helper'

class EmptyCart
  include ROXML

  xml_reader :id

  def empty?
    true
  end
end

class CartHolder
  include ROXML

  xml_reader :cart, :as => EmptyCart, :required => true
end

class TestXMLObject < ActiveSupport::TestCase
  # Test book with text and attribute
  def test_book_author_text_attribute
    book = BookWithAuthorTextAttribute.from_xml(fixture(:book_text_with_attribute))
    assert_equal("primary",book.author.role)
    assert_equal("David Thomas",book.author.text)
  end

  # Test XML object containing list of other XML objects (one-to-many)
  # In this case, book with contibutions
  def test_one_to_many_with_container
    expected_authors = ["David Thomas","Andrew Hunt","Chad Fowler"]
    book = BookWithContributions.from_xml(fixture(:book_with_contributions))
    assert_equal("Programming Ruby - 2nd Edition", book.title)
    book.contributions.each do |contributor|
      assert expected_authors.include?(contributor.name)
    end
  end

  # Test XML object containing 1-n other XML objects without container (one-to-many)
  # In this case, book with contibutions
  def test_one_to_many_without_container
    expected_contributors = ["David Thomas","Andrew Hunt","Chad Fowler"]
    book = BookWithContributors.from_xml(fixture(:book_with_contributors))
    assert_equal("Programming Ruby - 2nd Edition", book.title)
    book.contributors.each do |contributor|
      assert(expected_contributors.include?(contributor.name))
    end
  end

  # when building objects that contain arrays, the second object seems to
  # inherit data from the first
  #
  def test_one_to_many_without_container_sequence
    contrib = WriteableContributor.new
    contrib.name = "David Thomas"

    book_one = WriteableBookWithContributors.new
    book_one.isbn = "9781843549161"
    book_one.title = "Anathem"
    book_one.description = "A new title from Neal Stephenson"
    book_one.contributors = [contrib]

    # this book should be completely empty
    book_two = WriteableBookWithContributors.new

    assert_equal(nil, book_two.isbn)
    assert_equal(nil, book_two.title)
    assert_equal(nil, book_two.description)
    assert_equal(nil, book_two.contributors)
  end

  # Test XML object containing one other XML object (one-to-one)
  # In this case, book with publisher
  def test_one_to_one
    book = BookWithPublisher.from_xml(fixture(:book_with_publisher))
    assert_equal("Programming Ruby - 2nd Edition", book.title)
    assert_equal("Pragmatic Bookshelf", book.publisher.name)
  end

  # Test XML object containing type of self (self-reference)
  def test_self_reference
    book = BookPair.from_xml(fixture(:book_pair))
    assert_equal("Programming Ruby - 2nd Edition", book.title)
    assert_equal("Agile Web Development with Rails", book.book.title)
  end

  # Test three-level composition (one-to-many-to-many)
  def test_one_to_many_to_many
    expected_contributors = ["David Thomas","Andrew Hunt","Chad Fowler", "David Heinemeier Hansson"]
    expected_books = ["Programming Ruby - 2nd Edition", "Agile Web Development with Rails"]
    library = Library.from_xml(fixture(:library))
    assert_equal("Ruby library", library.name)
    assert !library.books.empty?
    library.books.each do |book|
      assert expected_books.include?(book.title)
      book.contributions.each do |contributor|
        assert(expected_contributors.include?(contributor.name))
      end
    end
  end

  def test_without_needed_from
    assert_equal [], UppercaseLibrary.from_xml(fixture(:library)).books
    assert_equal [], Library.from_xml(fixture(:library_uppercase)).books
  end

  def test_with_needed_from
    assert Library.from_xml(fixture(:library)).books
    assert UppercaseLibrary.from_xml(fixture(:library_uppercase)).books
  end

  def test_with_recursion
    p = PersonWithMother.from_xml(fixture(:person_with_mothers))
    assert_equal 'Ben Franklin', p.name
    assert_equal 'Abiah Folger', p.mother.name
    assert_equal 'Madeup Mother', p.mother.mother.name
    assert_equal nil, p.mother.mother.mother
  end

  class Node
    include ROXML

    xml_reader :name, :from => 'node_name'
    xml_reader :nodes, :as => [Node]
  end

  class Taxonomy
    include ROXML

    xml_reader :name, :from => 'taxonomy_name'
    xml_reader :nodes, :as => [Node]
  end

  class Taxonomies
    include ROXML
    xml_reader :taxonomies, :as => [Taxonomy]
  end

  def test_more_recursion
    taxonomies = Taxonomies.from_xml(<<HERE)
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE taxonomies SYSTEM "taxonomy.dtd">
<taxonomies>
	<taxonomy>
		<taxonomy_name>World</taxonomy_name>
		<node node_id="2" content_object_id="82534" object_type_id="2">
			<node_name lang_iso="eng">Africa</node_name>
			<node node_id="331" content_object_id="11" object_type_id="4">
				<node_name lang_iso="eng">Algeria</node_name>
				<node node_id="7271" content_object_id="117629" object_type_id="8">
					<node_name lang_iso="eng">Algiers</node_name>
				</node>
				<node node_id="7272" content_object_id="117630" object_type_id="8">
					<node_name lang_iso="eng">Gharda&#239;a</node_name>
				</node>
				<node node_id="7871" content_object_id="1000713999" object_type_id="8">
					<node_name lang_iso="eng">El Oued</node_name>
				</node>
				<node node_id="7872" content_object_id="1000714008" object_type_id="8">
					<node_name lang_iso="eng">Timimoun</node_name>
				</node>
				<node node_id="8903" content_object_id="1000565565" object_type_id="8">
					<node_name lang_iso="eng">Annaba</node_name>
				</node>
			</node>
		</node>
	</taxonomy>
</taxonomies>
HERE
    assert_equal 1, taxonomies.taxonomies.size
    assert_equal 'World', taxonomies.taxonomies.first.name
    node = taxonomies.taxonomies.first.nodes.first
    assert_equal 'Africa', node.name
    assert_equal 'Algeria', node.nodes.first.name
    assert_equal ['Algiers', "Ghardaïa", 'El Oued', 'Timimoun', 'Annaba'],
      node.nodes.first.nodes.map(&:name)
  end

  def test_with_guarded_recursion
    p = PersonWithGuardedMother.from_xml(fixture(:person_with_guarded_mothers))
    assert_equal 'Ben "Benji" Franklin', p.name
    assert_equal 'Abiah \'Abby\' Folger', p.mother.name
    assert_equal 'Madeup Mother < the third >', p.mother.mother.name
    assert_equal nil, p.mother.mother.mother
  end

  def test_recursive_with_default_initialization
    p = PersonWithMotherOrMissing.from_xml(fixture(:person_with_mothers))
    assert_equal 'Unknown', p.mother.mother.mother.name
    assert_equal Person, p.mother.mother.mother.class
  end

  def test_defining_empty_on_object_doesnt_cause_it_to_be_seen_as_absent
    # absent means defaulting, failing required

    holder = CartHolder.from_xml(%{
      <cartholder>
        <cart>
          <id>111111</id>
        </cart>
      </cartholder>
    })

    assert_equal "111111", holder.cart.id
  end
end
