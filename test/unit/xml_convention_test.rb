require_relative './../test_helper'

XML_CAMELLOWER = %{
  <bookCase name="Jonas' Books">
    <bookCount>12</bookCount>
    <bigBooks>
      <bigBook>GED</bigBook>
      <bigBook>House of Leaves</bigBook>
    </bigBooks>
  </bookCase>
}

XML_CAMELCASE = %{
  <BookCase Name="Jonas' Books">
    <BookCount>12</BookCount>
    <BigBooks>
      <BigBook>GED</BigBook>
      <BigBook>House of Leaves</BigBook>
    </BigBooks>
  </BookCase>
}

XML_UNDERSCORE = %{
  <book_case name="Jonas' Books">
    <book_count>12</book_count>
    <big_books>
      <big_book>GED</big_book>
      <big_book>House of Leaves</big_book>
    </big_books>
  </book_case>
}

XML_DASHES = %{
  <book-case name="Jonas' Books">
    <book-count>12</book-count>
    <big-books>
      <big-book>GED</big-book>
      <big-book>House of Leaves</big-book>
    </big-books>
  </book-case>
}

XML_UPCASE = %{
  <BOOKCASE NAME="Jonas' Books">
    <BOOKCOUNT>12</BOOKCOUNT>
    <BIGBOOKS>
      <BIGBOOK>GED</BIGBOOK>
      <BIGBOOK>House of Leaves</BIGBOOK>
    </BIGBOOKS>
  </BOOKCASE>
}

class BookCase
  include ROXML

  xml_reader :book_count, :as => Integer, :required => true
  xml_reader :big_books, :as => [], :required => true
end

class BookCaseCamelCase < BookCase
  xml_convention :camelcase
end

class BookCaseUnderScore < BookCase
  xml_convention :underscore
end

class BookCaseDashes < BookCase
  xml_convention &:dasherize
end

class BookCaseCamelLower < BookCase
  xml_convention {|val| val.camelcase(:lower) }
end

class BookCaseUpCase < BookCase
  xml_convention {|val| val.gsub('_', '').upcase }
end

class InheritedBookCaseCamelCase < BookCaseCamelCase
end

class InheritedBookCaseUpCase < BookCaseUpCase
end

# Same as BookCase.  Needed to keep BookCase clean for other tests
class ParentBookCaseDefault
  include ROXML

  xml_reader :book_count, :as => Integer, :required => true
  xml_reader :big_books, :as => [], :required => true
end

class InheritedBookCaseDefault < ParentBookCaseDefault
end

class TestXMLConvention < ActiveSupport::TestCase
  # TODO: Test convention applies to xml_name as well...

  def test_default_convention_is_underscore
    bc = BookCase.from_xml(XML_UNDERSCORE)
    assert_has_book_case_info(bc)
  end

  [BookCaseUpCase, BookCaseCamelLower, BookCaseDashes, BookCaseUnderScore, BookCaseCamelCase].each do |klass|
    define_method(:"test_xml_convention_#{klass.to_s.underscore}") do
      data = :"XML_#{klass.to_s.sub('BookCase', '').upcase}"
      assert_equal Proc, klass.roxml_naming_convention.class

      bc = klass.from_xml(Object.const_get(data))
      assert_has_book_case_info(bc)
    end
  end

  def test_child_should_inherit_convention_if_it_doesnt_declare_one
    [InheritedBookCaseUpCase, InheritedBookCaseCamelCase].each do |klass|
      data = :"XML_#{klass.to_s.sub('InheritedBookCase', '').upcase}"
      assert_equal Proc, klass.roxml_naming_convention.class

      bc = klass.from_xml(Object.const_get(data))
      assert_has_book_case_info(bc)
    end
  end

  def test_child_should_inherit_convention_even_if_it_is_added_after_child_declaration
    bc = InheritedBookCaseDefault.from_xml(XML_UNDERSCORE)
    assert_has_book_case_info(bc)

    ParentBookCaseDefault.class_eval do
      xml_convention :dasherize
    end

    bc = InheritedBookCaseDefault.from_xml(XML_DASHES)
    assert_has_book_case_info(bc)
    assert_raise ROXML::RequiredElementMissing do
      InheritedBookCaseDefault.from_xml(XML_UNDERSCORE)
    end
  end

  def test_tag_name_should_get_convention_treatment_as_well
    assert_equal "book-case-dashes", BookCaseDashes.tag_name
    assert_equal "INHERITEDBOOKCASEUPCASE", InheritedBookCaseUpCase.tag_name
    assert_equal "InheritedBookCaseCamelCase", InheritedBookCaseCamelCase.tag_name
  end

  def assert_has_book_case_info(bc)
    assert_equal 12, bc.book_count
    assert_equal ['GED', 'House of Leaves'], bc.big_books
  end
end