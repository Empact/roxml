require 'lib/roxml'
require 'rubygems'
require 'active_support/core_ext/module/aliasing'
require 'active_support/callbacks'
require 'active_support/test_case'

require File.join(File.dirname(__FILE__), '..', 'test_helper')

#      Parent        |    Child
#  :from  | no :from |
# -------------------|--------------
#  :from  | xml_name | xml_name-d
#  value  |  value   |
# -------------------|--------------
#  :from  | parent's |
#  value  | accessor | un-xml_name-d
#         |  name    |

class Child
  include ROXML
end

class NamedChild
  include ROXML

  xml_name :xml_name_of_child
end

class ParentOfNamedChild
  include ROXML

  xml_name :parent
  xml_accessor :child_accessor_name, NamedChild
end

class ParentOfNamedChildWithFrom
  include ROXML

  xml_name :parent
  xml_accessor :child_accessor_name, NamedChild, :from => 'child_from_name'
end

class ParentOfUnnamedChild
  include ROXML

  xml_name :parent
  xml_accessor :child_accessor_name, Child
end

class ParentOfUnnamedChildWithFrom
  include ROXML

  xml_name :parent
  xml_accessor :child_accessor_name, Child, :from => 'child_from_name'
end

class TestXMLName < Test::Unit::TestCase
  def test_from_always_dominates_attribute_name_xml_name_or_not
    parent = ParentOfNamedChildWithFrom.new
    parent.child_accessor_name = Child.new

    assert_equal "<parent>\n  <child_from_name/>\n</parent>", parent.to_xml.to_s

    parent = ParentOfUnnamedChildWithFrom.new
    parent.child_accessor_name = Child.new

    assert_equal "<parent>\n  <child_from_name/>\n</parent>", parent.to_xml.to_s
  end

  def test_attribute_name_comes_from_the_xml_name_value_if_present
    parent = ParentOfNamedChild.new
    parent.child_accessor_name = Child.new

    assert_equal "<parent>\n  <xml_name_of_child/>\n</parent>", parent.to_xml.to_s
  end

  def test_attribute_name_comes_from_parent_accessor_by_default
    parent = ParentOfUnnamedChild.new
    parent.child_accessor_name = Child.new

    assert_equal "<parent>\n  <child_accessor_name/>\n</parent>", parent.to_xml.to_s
  end

  def test_named_books_picked_up
    named = Library.from_xml(fixture(:library))
    assert named.books
    assert_equal :book, named.books.first.tag_name
  end

  def test_nameless_books_missing
    nameless = LibraryWithBooksOfUnderivableName.from_xml(fixture(:library))
    assert nameless.novels.empty?
  end

  def test_tag_name
    assert_equal :dictionary, DictionaryOfTexts.tag_name

    dict = DictionaryOfTexts.from_xml(fixture(:dictionary_of_texts))

    assert_equal :dictionary, dict.tag_name
  end

  def test_tag_refs
    assert_equal 'definition', DictionaryOfTexts.tag_refs.only.name
    assert_equal 'word', DictionaryOfTexts.tag_refs.only.hash.key.name
    assert_equal 'meaning', DictionaryOfTexts.tag_refs.only.hash.value.name

    dict = DictionaryOfTexts.from_xml(fixture(:dictionary_of_texts))

    assert_equal 'definition', dict.tag_refs.only.name
    assert_equal 'word', dict.tag_refs.only.hash.key.name
    assert_equal 'meaning', dict.tag_refs.only.hash.value.name
  end
end