require File.join(File.dirname(__FILE__), '..', 'test_helper')

class TestDefaultXMLNamespaces < ActiveSupport::TestCase
  def setup
    @book = BookWithContributions.from_xml(fixture(:book_with_default_namespace))
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
    require 'rexml/document'
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
  rescue LoadError
  end
end

class NamespaceyObject
  include ROXML
  xml_namespace :aws

  xml_reader :default_namespace
  xml_reader :different_namespace, :from => 'different:namespace'
  xml_reader :no_namespace, :from => 'no_namespace'
end

class TestXMLNamespaceDeclarations < ActiveSupport::TestCase
  def setup
    @instance = NamespaceyObject.from_xml(%{
      <aws:book xmlns:aws="http://www.aws.com/aws" xmlns:different="http://www.aws.com/different">
        <aws:default_namespace>default_value</aws:default_namespace>
        <different:namespace>different_value</different:namespace>
        <no_namespace>no_value</no_namespace>
      </aws:book>
    })
  end

  def test_namespace_is_accessible
    assert_equal "aws", @instance.class.roxml_namespace
  end

  def test_namespace_declaration_should_be_followed_on_attributes
    assert_equal "default_value", @instance.default_namespace
  end

  def test_namespace_declaration_can_be_overriden_for_different_namespace_elements
    assert_equal "different_value", @instance.different_namespace
  end

  def test_namespace_declaration_can_be_overriden_for_no_namespace_elements
    assert_equal "no_value", @instance.no_namespace
  end
end