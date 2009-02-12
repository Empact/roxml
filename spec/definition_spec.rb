require File.dirname(__FILE__) + '/spec_helper.rb'

describe ROXML::Definition do
  describe "#name_explicit?" do
    it "should indicate whether from option is present" do
      ROXML::Definition.new(:element, :from => 'somewhere').name_explicit?.should be_true
      ROXML::Definition.new(:element).name_explicit?.should be_false
    end
  end

  describe "hash options declaration", :shared => true do
    it "should represent a hash" do
      @opts.hash?.should be_true
    end

    it "should have hash definition" do
      {@opts.hash.key.type => @opts.hash.key.name}.should == @hash_args[:key]
      {@opts.hash.value.type => @opts.hash.value.name}.should == @hash_args[:value]
    end

    it "should not represent an array" do
      @opts.array?.should be_false
    end
  end

  describe "types" do
    describe ":content" do
      it "should be recognized" do
        ROXML::Definition.new(:author).content?.should be_false
        ROXML::Definition.new(:author, :content).content?.should be_true
      end

      it "should be deprecated"
    end

    describe "array reference" do
      it "[] means array of texts" do
        opts = ROXML::Definition.new(:authors, [])
        opts.array?.should be_true
        opts.type.should == :text
      end

      it "[:text] means array of texts" do
        opts = ROXML::Definition.new(:authors, [:text])
        opts.array?.should be_true
        opts.type.should == :text
      end

      it "[:attr] means array of attrs" do
        opts = ROXML::Definition.new(:authors, [:attr])
        opts.array?.should be_true
        opts.type.should == :attr
      end

      it "[Object] means array of objects" do
        opts = ROXML::Definition.new(:authors, [Hash])
        opts.array?.should be_true
        opts.type.should == Hash
      end
    end

    describe "{}" do
      describe "hash with attr key and text val" do
        before do
          @opts = ROXML::Definition.new(:attributes, {:key => {:attr => :name},
                                         :value => :value})
          @hash_args = {:key => {:attr => 'name'},
                        :value => {:text => 'value'}}
        end

        it_should_behave_like "hash options declaration"
      end

      describe "hash with String class for type" do
        before do
          @opts = ROXML::Definition.new(:attributes, {:key => {String => 'name'},
                                         :value => {String => 'value'}})
          @hash_args = {:key => {:text => 'name'}, :value => {:text => 'value'}}
        end

        it_should_behave_like "hash options declaration"
      end

      describe "hash with attr key and content val" do
        before do
          @opts = ROXML::Definition.new(:attributes, {:key => {:attr => :name},
                                         :value => :content})
          @hash_args = {:key => {:attr => 'name'}, :value => {:text => '.'}}
        end

        it_should_behave_like "hash options declaration"
      end

      describe "hash of attrs" do
        before do
          @hash_args = {:key => {:attr => 'name'}, :value => {:attr => 'value'}}
          @opts = ROXML::Definition.new(:attributes, {:attrs => [:name, :value]})
        end

        it_should_behave_like "hash options declaration"

        describe "with options" do
          before do
            @hash_args = {:key => {:attr => 'dt'}, :value => {:attr => 'dd'}}
            @opts = ROXML::Definition.new(:definitions, {:attrs => [:dt, :dd]},
                                    :in => 'definitions')
          end

          it_should_behave_like "hash options declaration"

          it "should not interfere with options" do
            @opts.wrapper.should == 'definitions'
          end
        end
      end
    end
  end

  describe ":as" do
    describe "=> :array" do
      it "should be deprecated"
    end

    describe "=> []" do
      it "should means array of texts" do
        opts = ROXML::Definition.new(:authors, :as => [])
        opts.array?.should be_true
        opts.type.should == :text
      end
    end

    describe "=> {}" do
      describe "hash with attr key and text val" do
        before do
          @opts = ROXML::Definition.new(:attributes, :as => {:key => {:attr => :name},
                                                             :value => :value})
          @hash_args = {:key => {:attr => 'name'},
                        :value => {:text => 'value'}}
        end

        it_should_behave_like "hash options declaration"
      end

      describe "hash with String class for type" do
        before do
          @opts = ROXML::Definition.new(:attributes, :as => {:key => {String => 'name'},
                                                             :value => {String => 'value'}})
          @hash_args = {:key => {:text => 'name'}, :value => {:text => 'value'}}
        end

        it_should_behave_like "hash options declaration"
      end

      describe "hash with attr key and content val" do
        before do
          @opts = ROXML::Definition.new(:attributes, :as => {:key => {:attr => :name},
                                                             :value => :content})
          @hash_args = {:key => {:attr => 'name'}, :value => {:text => '.'}}
        end

        it_should_behave_like "hash options declaration"
      end

      describe "hash of attrs" do
        before do
          @hash_args = {:key => {:attr => 'name'}, :value => {:attr => 'value'}}
          @opts = ROXML::Definition.new(:attributes, :as => {:attrs => [:name, :value]})
        end

        it_should_behave_like "hash options declaration"

        describe "with options" do
          before do
            @hash_args = {:key => {:attr => 'dt'}, :value => {:attr => 'dd'}}
            @opts = ROXML::Definition.new(:definitions, :as => {:attrs => [:dt, :dd]},
                                    :in => 'definitions')
          end

          it_should_behave_like "hash options declaration"

          it "should not interfere with options" do
            @opts.wrapper.should == 'definitions'
          end
        end
      end
    end

    describe "for block shorthand" do
      describe "in literal array" do
        before do
          @opts = ROXML::Definition.new(:intarray, :as => [Integer])
        end

        it "should be detected as array reference" do
          @opts.array?.should be_true
        end

        it "should be normal otherwise" do
          @opts.type.should == :text
          @opts.blocks.size.should == 1
        end
      end

      it "should have no blocks without a shorthand" do
        ROXML::Definition.new(:count).blocks.should be_empty
        ROXML::Definition.new(:count, :as => :bogus).blocks.should be_empty
        ROXML::Definition.new(:count, :as => :foat).blocks.should be_empty # misspelled
      end

      describe ":as => Integer", :shared => true do
        it "should translate empty strings to nil" do
          @definition.blocks.first.call("").should be_nil
          @definition.blocks.first.call(" ").should be_nil
        end

        it "should translate text to integers" do
          @definition.blocks.first['3'].should == 3
          @definition.blocks.first['792'].should == 792
        end

        it "should raise on non-integer values" do
          proc { @definition.blocks.first['793.12'] }.should raise_error(ArgumentError)
          proc { @definition.blocks.first['junk 11'] }.should raise_error(ArgumentError)
          proc { @definition.blocks.first['11sttf'] }.should raise_error(ArgumentError)
        end

        context "when passed an array" do
          it "should translate the array elements to integer" do
            @definition.blocks.first.call(["792", "12", "328"]).should == [792, 12, 328]
          end
        end
      end

      describe "Integer" do
        before do
          @definition = ROXML::Definition.new(:intvalue, :as => Integer)
          @definition_required = ROXML::Definition.new(:intvalue, :as => Integer, :required => true)
        end

        it_should_behave_like ":as => Integer"
      end

      describe ":integer" do
        before do
          @definition = ROXML::Definition.new(:intvalue, :as => :integer)
          @definition_required = ROXML::Definition.new(:intvalue, :as => :integer, :required => true)
        end

        it_should_behave_like ":as => Integer"

        it "should be deprecated"
      end

      describe ":as => Float", :shared => true do
        it "should translate empty strings to nil" do
          @definition.blocks.first.call("").should be_nil
          @definition.blocks.first.call(" ").should be_nil
        end

        it "should translate text to float" do
          @definition.blocks.first['3'].should == 3.0
          @definition.blocks.first['12.7'].should == 12.7
        end

        it "should raise on non-float values" do
          proc { @definition.blocks.first['junk 11.3'] }.should raise_error(ArgumentError)
          proc { @definition.blocks.first['11.1sttf'] }.should raise_error(ArgumentError)
        end

        context "when passed an array" do
          it "should translate the array elements to integer" do
            @definition.blocks.first.call(["792.13", "240", "3.14"]).should == [792.13, 240.0, 3.14]
          end
        end
      end

      describe ":float" do
        before do
          @definition = ROXML::Definition.new(:floatvalue, :as => :float)
        end

        it_should_behave_like ":as => Float"

        it "should be deprecated"
      end

      describe "Float" do
        before do
          @definition = ROXML::Definition.new(:floatvalue, :as => Float)
        end

        it_should_behave_like ":as => Float"
      end

      describe ":as => BigDecimal", :shared => true do
        it "should translate empty strings to nil" do
          @definition.blocks.first.call(nil).should be_nil
          @definition.blocks.first.call("").should be_nil
          @definition.blocks.first.call(" ").should be_nil
        end

        it "should translate text to decimal numbers" do
          @definition.blocks.first['3'].should == BigDecimal.new("3.0")
          @definition.blocks.first['0.3'].should == BigDecimal.new("0.3")
        end

        it "should extract what it can, and fall back to 0" do
          @definition.blocks.first['junk 11'].should eql(BigDecimal.new("0"))
          @definition.blocks.first['11sttf'].should eql(BigDecimal.new("11.0"))
        end

        context "when passed an array" do
          it "should translate the array elements to integer" do
            @definition.blocks.first.call(["12.1", "328.2"]).should == [BigDecimal.new("12.1"), BigDecimal.new("328.2")]
          end
        end
      end

      describe "BigDecimal" do
        before do
          @definition = ROXML::Definition.new(:decimalvalue, :as => BigDecimal)
          @definition_required = ROXML::Definition.new(:decimalvalue, :as => BigDecimal, :required => true)
        end

        it_should_behave_like ":as => BigDecimal"
      end

      describe ":bool" do
        it "should boolify individual values" do
          ROXML::Definition.new(:floatvalue, :as => :bool).blocks.first.call("1").should be_true
          ROXML::Definition.new(:floatvalue, :as => :bool).blocks.first.call("True").should be_true
          ROXML::Definition.new(:floatvalue, :as => :bool).blocks.first.call("Yes").should be_true
        end

        context "when an array is passed in" do
          it "should boolify arrays of values" do
            ROXML::Definition.new(:floatvalue, :as => :bool).blocks.first.call("0").should be_false
            ROXML::Definition.new(:floatvalue, :as => :bool).blocks.first.call("false").should be_false
            ROXML::Definition.new(:floatvalue, :as => :bool).blocks.first.call("nO").should be_false
          end
        end

        context "when no value is detected" do
          it "should return nil" do
            ROXML::Definition.new(:floatvalue, :as => :bool).blocks.first.call("junk").should be_nil
          end

          context "when a literal block is available" do
            it "should pass the value itself to the block"
          end
        end
      end

      describe "Time" do
        it "should return nil on empty string" do
          ROXML::Definition.new(:floatvalue, :as => Time).blocks.first.call("  ").should be_nil
        end

        it "should return a time version of the string" do
          ROXML::Definition.new(:datevalue, :as => Time).blocks.first.call("12:31am").min.should == 31
        end

        context "when passed an array of values" do
          it "should timify all of them" do
            ROXML::Definition.new(:datevalue, :as => Time).blocks.first.call(["12:31am", "3:00pm", "11:59pm"]).map(&:min).should == [31, 0, 59]
          end
        end
      end

      describe "Date" do
        it "should return nil on empty string" do
          ROXML::Definition.new(:floatvalue, :as => Date).blocks.first.call("  ").should be_nil
        end

        it "should return a time version of the string" do
          ROXML::Definition.new(:datevalue, :as => Date).blocks.first.call("September 3rd, 1970").to_s == "1970-09-03"
        end

        context "when passed an array of values" do
          it "should timify all of them" do
            ROXML::Definition.new(:datevalue, :as => Date).blocks.first.call(["September 3rd, 1970", "1776-07-04"]).map(&:to_s).should == ["1970-09-03", "1776-07-04"]
          end
        end
      end

      describe "DateTime" do
        it "should return nil on empty string" do
          ROXML::Definition.new(:floatvalue, :as => DateTime).blocks.first.call("  ").should be_nil
        end

        it "should return a time version of the string" do
          ROXML::Definition.new(:datevalue, :as => DateTime).blocks.first.call("12:05pm, September 3rd, 1970").to_s == "1970-09-03T12:05:00+00:00"
        end

        context "when passed an array of values" do
          it "should timify all of them" do
            ROXML::Definition.new(:datevalue, :as => DateTime).blocks.first.call(["12:05pm, September 3rd, 1970", "3:00pm, May 22, 1700"]).map(&:to_s).should == ["1970-09-03T12:05:00+00:00", "1700-05-22T15:00:00+00:00"]
          end
        end
      end

      it "should prohibit multiple shorthands" do
        proc { ROXML::Definition.new(:count, :as => [Float, Integer]) }.should raise_error(ArgumentError)
      end

      it "should stack block shorthands with explicit blocks" do
        ROXML::Definition.new(:count, :as => Integer) {|val| val.to_i }.blocks.size.should == 2
        ROXML::Definition.new(:count, :as => Float) {|val| val.object_id }.blocks.size.should == 2
      end
    end
  end

  describe ":from" do
    describe "attribute reference", :shared => true do
      it "should be interpreted as :attr" do
        @opts.type.should == :attr
      end

      it "should strip '@' from name" do
        @opts.name.should == 'attr_name'
      end
    end

    context ":attr" do
      before do
        @opts = ROXML::Definition.new(:attr_name, :from => :attr)
      end

      it_should_behave_like "attribute reference"
    end

    context "@attribute_name" do
      before do
        @opts = ROXML::Definition.new(:doesntmatter, :from => '@attr_name')
      end

      it_should_behave_like "attribute reference"

      describe "and with :attr" do
        before do
          @opts = ROXML::Definition.new(:doesntmatter, :attr, :from => '@attr_name')
        end

        it_should_behave_like "attribute reference"
        it "should be deprecated"
      end
    end

    describe ":content" do
      it "should be recognized" do
        ROXML::Definition.new(:author, :from => :content).content?.should == true
      end

      it "should be equivalent to :from => '.'" do
        ROXML::Definition.new(:author, :from => '.').content?.should == true
      end
    end
  end

  describe ":in" do
    context "as xpath" do
      it "should pass through as wrapper" do
        ROXML::Definition.new(:manufacturer, :in => './').wrapper.should == './'
      end
    end

    context "as xpath" do
      it "should pass through as wrapper" do
        ROXML::Definition.new(:manufacturer, :in => 'wrapper').wrapper.should == 'wrapper'
      end
    end
  end

  describe "options" do

    describe "boolean option", :shared => true do
      it "should be recognized" do
        ROXML::Definition.new(:author, :content, @option => true).respond_to?(:"#{@option}?")
        ROXML::Definition.new(:author, :content, @option => true).send(:"#{@option}?").should be_true
        ROXML::Definition.new(:author, :content, @option => false).send(:"#{@option}?").should be_false
      end

      it "should default to false" do
        ROXML::Definition.new(:author, :content).send(:"#{@option}?").should be_false
      end
    end

    describe ":required" do
      before do
        @option = :required
      end

      it_should_behave_like "boolean option"

      it "should not be allowed together with :else" do
        proc { ROXML::Definition.new(:author, :content, :required => true, :else => 'Johnny') }.should raise_error(ArgumentError)
        proc { ROXML::Definition.new(:author, :content, :required => false, :else => 'Johnny') }.should_not raise_error
      end
    end

    describe ":frozen" do
      before do
        @option = :frozen
      end

      it_should_behave_like "boolean option"
    end

    describe ":cdata" do
      before do
        @option = :cdata
      end

      it_should_behave_like "boolean option"
    end
  end
end
