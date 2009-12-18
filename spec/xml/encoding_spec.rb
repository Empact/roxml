require 'spec/spec_helper'

describe ROXML, "encoding" do
  class TestResult
    include ROXML
    xml_accessor :message
  end

  context "when provided non-latin characters" do
    it "should output those characters as input via methods" do
      res = TestResult.new
      res.message = "sadfk одловыа jjklsd " #random russian  and english charecters
      res.to_xml.at('message').inner_text.should == "sadfk одловыа jjklsd "
    end

    it "should output those characters as input via xml" do
      res = TestResult.from_xml("<test_result><message>sadfk одловыа jjklsd </message></test_result>")
      res.to_xml.at('message').inner_text.should == "sadfk одловыа jjklsd "
    end
  end

end