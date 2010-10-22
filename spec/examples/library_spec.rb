require_relative './../spec_helper'
require_relative './../../examples/library'

describe Library do
  before :all do
    book = Novel.new
    book.isbn = "0201710897"
    book.title = "The PickAxe"
    book.description = "Best Ruby book out there!"
    book.author = "David Thomas, Andrew Hunt, Dave Thomas"
    book.publisher = Publisher.new('Addison Wesley Longman, Inc.')

    @lib = Library.new
    @lib.name = "Favorite Books"
    @lib.novels = [book]
  end

  describe "#to_xml" do
    it "should contain the expected information" do
      @lib.to_xml.to_s.should == ROXML::XML.parse_string(%{<library><NAME><![CDATA[Favorite Books]]></NAME><novel ISBN='0201710897'><title>The PickAxe</title><description><![CDATA[Best Ruby book out there!]]></description><author>David Thomas, Andrew Hunt, Dave Thomas</author><publisher><name>Addison Wesley Longman, Inc.</name></publisher></novel></library>}).root.to_s
    end

    context "when written to a file" do
      before :all do
        @path = "spec/examples/library.xml"
        @doc = ROXML::XML::Document.new
        @doc.root = @lib.to_xml
        ROXML::XML.save_doc(@doc, @path)
      end

     after :all do
       FileUtils.rm @path
     end

     it "should be contain the expected xml" do
        ROXML::XML.parse_string(File.read(@path)).to_s.should == ROXML::XML.parse_string(%{<?xml version="1.0"?><library><NAME><![CDATA[Favorite Books]]></NAME><novel ISBN='0201710897'><title>The PickAxe</title><description><![CDATA[Best Ruby book out there!]]></description><author>David Thomas, Andrew Hunt, Dave Thomas</author><publisher><name>Addison Wesley Longman, Inc.</name></publisher></novel></library>}).to_s
      end

      it "should be re-parsable via .from_xml" do
        File.open("spec/examples/library.xml") do |file|
          Library.from_xml(file).should == @lib
        end
      end
    end
  end
end
