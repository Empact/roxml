class OctalInteger
  def self.from_xml(val)
    new(Integer(val.content))
  end

  def initialize(value)
    @val = value
  end

  def ==(other)
    @val == other
  end

  def to_xml
    sprintf("%#o", @val)
  end
end

class BookWithOctalPages
  include ROXML

  xml_accessor :pages_with_to_xml_proc, :as => Integer, :to_xml => proc {|val| sprintf("%#o", val) }, :required => true
  xml_accessor :pages_with_type, OctalInteger, :required => true
end

class TestToXmlWithOverriddenOutput < Test::Unit::TestCase
  to_xml_test :book_with_octal_pages
  def test_padded_numbers_read_properly
    b = BookWithOctalPages.from_xml(fixture(:book_with_octal_pages))
    assert_equal 239, b.pages_with_type
    assert_equal 239, b.pages_with_to_xml_proc
  end
end