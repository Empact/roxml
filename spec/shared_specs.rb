if defined?(shared_examples_for)
  shared_examples_for "freezable xml reference" do
    describe "with :frozen option" do
      it "should be frozen" do
        expect(@frozen.frozen?).to be_truthy
      end
    end

    describe "without :frozen option" do
      it "should not be frozen" do
        expect(@unfrozen.frozen?).to be_falsey
      end
    end
  end
end
