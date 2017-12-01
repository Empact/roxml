require 'spec_helper'
require_relative './../../examples/amazon'

describe PITA::ItemSearchResponse do
  before do
    @response = PITA::ItemSearchResponse.from_xml(xml_for('amazon'))
  end

  describe "#total_results" do
    it "should be parsed as a number" do
      expect(@response.total_results).to be > 0
    end
  end

  describe "#total_pages" do
    it "should be parsed as a number" do
      expect(@response.total_pages).to be > 0
    end
  end

  describe "#items" do
    it "should return a collection of items" do
      expect(@response.items).to be_an_instance_of(Array)
      expect(@response.items.size).to be > 0
      @response.items.each {|item| expect(item).to be_an_instance_of(PITA::Item) }
    end

    it "should have the some number less than or equal to #total_results" do
      expect(@response.items.size).to be > 0
      expect(@response.items.size).to be <= @response.total_results
    end
  end
end

describe PITA::Item do
  before do
    @items = PITA::ItemSearchResponse.from_xml(xml_for('amazon')).items
  end

  it "should extract asin" do
    @items.each {|item| expect(item.asin).to be_an_instance_of(String) }
    @items.each {|item| expect(item.asin).to_not be_empty }
  end

  it "should extract detail_page_url" do
    @items.each {|item| expect(item.detail_page_url).to be_an_instance_of(String) }
    @items.each {|item| expect(item.detail_page_url).to_not be_empty }
  end

  it "should extract manufacturer" do
    @items.each {|item| expect(item.manufacturer).to be_an_instance_of(String) }
    @items.each {|item| expect(item.manufacturer).to_not be_empty }
  end
end