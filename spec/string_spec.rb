require File.dirname(__FILE__) + '/spec_helper.rb'

describe String do
  describe "#to_latin" do
    it "should be accessible" do
      "".should respond_to(:to_latin)
    end
  end

  describe "#to_utf" do
    it "should be accessible" do
      "".should respond_to(:to_utf)
    end
  end
end