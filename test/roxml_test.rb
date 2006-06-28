require "lib/roxml"
require "test/unit"
require "fixture_helper"
require "mocks/mocks"

class ROXMLTest < Test::Unit::TestCase
  include FixtureHelper
  
  def test_good_simple_mapping
    book = Book.parse(fixture(:book_good))
    assert_equal "The PickAxe", book.title
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