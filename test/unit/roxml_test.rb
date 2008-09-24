require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestROXML < Test::Unit::TestCase
  # Malformed XML parsing should throw REXML::ParseException
  def test_malformed
    ROXML::XML::Parser.register_error_handler {|err| }
    assert_raise ROXML::XML::Parser::ParseError do
      book = Book.parse(fixture(:book_malformed))
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
end
