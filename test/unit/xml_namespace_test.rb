require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestXMLNamespaces < Test::Unit::TestCase
  def setup
    @book = BookWithContributions.parse(fixture(:book_with_default_namespace))
  end

  def test_default_namespace_doesnt_interfere_with_normal_operation
    assert_equal("Programming Ruby - 2nd Edition", @book.title)
  end

  def test_default_namespace_is_applied_to_in_element
    expected_authors = ["David Thomas","Andrew Hunt","Chad Fowler"]
    assert !@book.contributions.empty?
    @book.contributions.each do |contributor|
      assert expected_authors.include?(contributor.name)
    end
  end

  def test_that_rexml_follows_nameless_default_namespace
    xml = REXML::Document.new(
      '<container xmlns="http://fakenamespace.org"><node>Yeah, content</node></container>')

    assert_equal "Yeah, content", xml.root.get_elements('node').first.text
  end

  def test_default_namespace_on_root_node_should_be_found
    require 'libxml'
    xml = LibXML::XML::Parser.string(
      '<container xmlns="http://defaultnamespace.org"><node>Yeah, content</node><node><subnode>Another</subnode></node></container>').parse

    assert_equal nil, xml.find_first('node')
    assert_equal "Yeah, content", xml.find_first('ns:node', 'ns:http://defaultnamespace.org').content
    assert_equal nil, xml.find_first('ns:node/subnode', 'ns:http://defaultnamespace.org')
    assert_equal "Another", xml.find_first('ns:node/ns:subnode', 'ns:http://defaultnamespace.org').content
  end
end