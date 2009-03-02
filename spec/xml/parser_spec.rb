require File.dirname(__FILE__) + '/../spec_helper.rb'

describe ROXML::XML::Parser do
  before do
    # quiet the error handler
    ROXML::XML::Error.reset_handler
  end
  
  it "should raise on malformed xml" do
    proc { Book.from_xml(fixture(:book_malformed)) }.should raise_error(ROXML::XML::Error)
  end

  it "should escape invalid characters on output to text node" do
    node = ROXML::XML::Node.new("entities")
    node.content = " < > ' \" & "
    if ROXML::XML_PARSER == 'libxml'
      node.to_s.should == "<entities> &lt; &gt; ' \" &amp; </entities>"
    else
      node.to_s.should == "<entities> &lt; &gt; &apos; &quot; &amp; </entities>"
    end
  end

  it "should esape invalid characters for attribute name" do
    node = ROXML::XML::Node.new("attr_holder")
    node.attributes["entities"] = "\"'<>&"
    if ROXML::XML_PARSER == 'libxml'
      node.to_s.should == %{<attr_holder entities="&quot;'&lt;&gt;&amp;"/>}
    else
      node.to_s.should == %{<attr_holder entities='&quot;&apos;&lt;&gt;&amp;'/>}
    end
  end
end