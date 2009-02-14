require File.dirname(__FILE__) + '/../spec_helper.rb'

describe ROXML::XML::Parser do
  before do
    # quiet the error handler
    ROXML::XML::Error.reset_handler
  end
  
  it "should raise on malformed xml" do
    proc { Book.from_xml(fixture(:book_malformed)) }.should raise_error(ROXML::XML::Error)
  end
end