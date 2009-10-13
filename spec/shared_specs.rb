require 'spec/spec_helper'

describe "freezable xml reference", :shared => true do
  describe "with :frozen option" do
    it "should be frozen" do
      @frozen.frozen?.should be_true
    end
  end

  describe "without :frozen option" do
    it "should not be frozen" do
      @unfrozen.frozen?.should be_false
    end
  end
end