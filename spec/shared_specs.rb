require_relative './spec_helper'

shared_examples_for "freezable xml reference" do
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