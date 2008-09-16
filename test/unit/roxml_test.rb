require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestROXML < Test::Unit::TestCase
  # Malformed XML parsing should throw REXML::ParseException
  def test_malformed
    LibXML::XML::Parser.register_error_handler {|err| }
    assert_raise LibXML::XML::Parser::ParseError do
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

  def test_block_with_xml_writer_should_be_rejected
    assert_raise ArgumentError do
      Class.new do
        include ROXML

        xml :id, true do |val|
          val * 3
        end
      end
    end
  end
end
