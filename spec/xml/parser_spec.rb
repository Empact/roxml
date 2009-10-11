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
    case ROXML::XML_PARSER
    when 'libxml', 'nokogiri'
      node.to_s.should == "<entities> &lt; &gt; ' \" &amp; </entities>"
    when 'rexml'
      node.to_s.should == "<entities> &lt; &gt; &apos; &quot; &amp; </entities>"
    else
      raise "Unrecognized Parser"
    end
  end

  it "should esape invalid characters for attribute name" do
    node = ROXML::XML::Node.create("attr_holder")
    node.attributes["entities"] = "\"'<>&"
    case ROXML::XML_PARSER
    when 'libxml', 'nokogiri'
      node.to_s.should == %{<attr_holder entities="&quot;'&lt;&gt;&amp;"/>}
    when 'rexml'
      node.to_s.should == %{<attr_holder entities='&quot;&apos;&lt;&gt;&amp;'/>}
    else
      raise "Unrecognized Parser"
    end
  end
end

describe ROXML::XML::Document do
  describe "#save" do
    context "with rexml parser" do
      it "should defer to existing XMLDecl" do
        if ROXML::XML_PARSER == 'rexml'
          @doc = ROXML::XML::Document.new
          @doc << REXML::XMLDecl.new('1.1')
          @doc.save('spec/xml/decl_test.xml')
          ROXML::XML::Parser.parse(File.read('spec/xml/decl_test.xml')).to_s.should == ROXML::XML::Parser.parse(%{<?xml version="1.1"?>}).to_s
        end
      end
    end
  end
end