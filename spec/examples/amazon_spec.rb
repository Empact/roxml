require example('amazon')

describe PITA::Items do
  before do
    @items = PITA::Items.from_xml(xml_for('amazon'))
  end

  describe "#total_results" do
    it "should be parsed as a number" do
      @items.total_results.should be_an_instance_of(Integer)
      @items.total_results.should > 0
    end
  end

  describe "#items" do
    it "should return a collection of items" do
      @items.items.should be_an_instance_of(Array)
      @items.items.each {|item| item.should be_an_instance_of(PITA::Item) }
    end

    it "should have the same number as the #total_results" do
      @items.items.size.should == @items.total_results
    end
  end
end

describe PITA::Item do
  before do
    @items = PITA::Items.from_xml(xml_for('amazon')).items
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
