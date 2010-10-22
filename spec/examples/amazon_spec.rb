require_relative './../spec_helper'
require_relative './../../examples/amazon'

describe PITA::ItemSearchResponse do
  before do
    @response = PITA::ItemSearchResponse.from_xml(xml_for('amazon'))
  end

  describe "#total_results" do
    it "should be parsed as a number" do
      @response.total_results.should > 0
    end
  end

  describe "#total_pages" do
    it "should be parsed as a number" do
      @response.total_pages.should > 0
    end
  end

  describe "#items" do
    it "should return a collection of items" do
      @response.items.should be_an_instance_of(Array)
      @response.items.size.should > 0
      @response.items.each {|item| item.should be_an_instance_of(PITA::Item) }
    end

    it "should have the some number less than or equal to #total_results" do
      @response.items.size.should > 0
      @response.items.size.should <= @response.total_results
    end
  end
end

describe PITA::Item do
  before do
    @items = PITA::ItemSearchResponse.from_xml(xml_for('amazon')).items
  end

  it "should extract asin" do
    @items.each {|item| item.asin.should be_an_instance_of(String) }
    @items.each {|item| item.asin.should_not be_empty }
  end

  it "should extract detail_page_url" do
    @items.each {|item| item.detail_page_url.should be_an_instance_of(String) }
    @items.each {|item| item.detail_page_url.should_not be_empty }
  end

  it "should extract manufacturer" do
    @items.each {|item| item.manufacturer.should be_an_instance_of(String) }
    @items.each {|item| item.manufacturer.should_not be_empty }
  end
end