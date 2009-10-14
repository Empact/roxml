require 'spec/spec_helper.rb'

describe ROXML::XML::Parser do
  before do
    # quiet the error handler
    ROXML::XML::Error.reset_handler if ROXML::XML::Error.respond_to?(:reset_handler)
  end
  
  it "should raise on malformed xml" do
    unless ROXML::XML_PARSER == 'nokogiri' # nokogiri is less strict and auto-closes for some reason
      proc { Book.from_xml(fixture(:book_malformed)) }.should raise_error(ROXML::XML::Error)
    end
  end

  it "should escape invalid characters on output to text node" do
    node = ROXML::XML::Node.create("entities")
    node.content = " < > ' \" & "
    node.to_s.should == "<entities> &lt; &gt; ' \" &amp; </entities>"
  end

  it "should esape invalid characters for attribute name" do
    node = ROXML::XML::Node.create("attr_holder")
    node.attributes["entities"] = "\"'<>&"
    node.to_s.should == %{<attr_holder entities="&quot;'&lt;&gt;&amp;"/>}
  end
end
