require File.join(File.dirname(__FILE__), '..', 'test_helper')

class RexmlBugs < Test::Unit::TestCase
  def test_that_some_illegal_chars_are_parsed_without_complaint
    p "REXML ignores illegal ']]>' brackets in xml content"
    assert_nothing_raised do
      # The right angle bracket (>) may be represented using the string "&gt;", and MUST, for compatibility,
      # be escaped using either "&gt;" or a character reference when it appears in the string "]]>" in content,
      # when that string is not marking the end of a CDATA section.
      # - http://www.w3.org/TR/xml11/#syntax
      xml = "<title>The Big Book of ]]> everything more</title>"
      assert_equal xml, REXML::Document.new(xml).to_s
    end
  end
end