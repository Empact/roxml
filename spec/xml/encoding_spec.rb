# encoding: utf-8
require_relative './../spec_helper'

describe ROXML, "encoding" do
  class TestResult
    include ROXML
    xml_accessor :message
  end
  
  context "when provided non-latin characters" do
    it "should output those characters as input via methods" do
      res = TestResult.new
      res.message = "sadfk одловыа jjklsd " #random russian  and english charecters
      doc = ROXML::XML::Document.new
      doc.root = res.to_xml
      if defined?(Nokogiri)
        doc.at('message').inner_text
      else
        doc.find_first('message').inner_xml
      end.should == "sadfk одловыа jjklsd "
    end
  
    it "should output those characters as input via xml" do
      res = TestResult.from_xml("<test_result><message>sadfk одловыа jjklsd </message></test_result>")
      doc = ROXML::XML::Document.new
      doc.root = res.to_xml
      if defined?(Nokogiri)
        doc.at('message').inner_text
      else
        doc.find_first('message').inner_xml
      end.should == "sadfk одловыа jjklsd "
    end
  
    it "should allow override via the document" do
      res = TestResult.from_xml("<test_result><message>sadfk одловыа jjklsd </message></test_result>")
      if defined?(Nokogiri)
        xml = res.to_xml
        doc = xml.document
        doc.root = xml
        doc.encoding = 'ISO-8859-1'
        doc.to_s.should include('ISO-8859-1')
        doc.at('message').inner_text
      else
        doc = LibXML::XML::Document.new
        doc.encoding = LibXML::XML::Encoding::ASCII
        doc.root = res.to_xml
        pending "Libxml bug"
        doc.to_s.should include('ISO-8859-1')
        doc.find_first('message').inner_xml
      end.should == "sadfk одловыа jjklsd "
    end
  end
end
