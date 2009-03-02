require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require example('library')

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
      @lib.to_xml.to_s.should == %{<library><NAME><![CDATA[Favorite Books]]></NAME><novel ISBN='0201710897'><title>The PickAxe</title><description><![CDATA[Best Ruby book out there!]]></description><author>David Thomas, Andrew Hunt, Dave Thomas</author><publisher><name>Addison Wesley Longman, Inc.</name></publisher></novel></library>}
    end

    context "when written to a file" do
      before :all do
        File.open("library.xml", "w") do |f|
          REXML::Formatters::Default.new.write(@lib.to_xml, f)
        end
      end

      it "should be contain the expected xml" do
        File.read("library.xml").should == %{<library><NAME><![CDATA[Favorite Books]]></NAME><novel ISBN='0201710897'><title>The PickAxe</title><description><![CDATA[Best Ruby book out there!]]></description><author>David Thomas, Andrew Hunt, Dave Thomas</author><publisher><name>Addison Wesley Longman, Inc.</name></publisher></novel></library>}
      end

      it "should be re-parsable via .from_xml" do
        lib = Library.from_xml(File.read("library.xml"))
        lib.should == @lib
      end
    end
  end
end
