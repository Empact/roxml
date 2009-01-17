require File.dirname(__FILE__) + '/../spec_helper.rb'

describe ROXML::XML::Parser do
  before do
    # quiet the error handler
    ROXML::XML::Parser.register_error_handler {|err| }
  end
  
  it "should raise on malformed xml" do
    proc { Book.from_xml(fixture(:book_malformed)) }.should raise_error(ROXML::XML::Parser::ParseError)
  end
end