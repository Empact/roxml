# encoding: utf-8
require_relative './spec_helper'

describe ROXML::Definition do
  describe "#name_explicit?" do
    it "should indicate whether from option is present" do
      ROXML::Definition.new(:element, :from => 'somewhere').name_explicit?.should be_true
      ROXML::Definition.new(:element).name_explicit?.should be_false
    end

    it "should not consider name proxies as explicit" do
      ROXML::Definition.new(:element, :from => :attr).name_explicit?.should be_false
      ROXML::Definition.new(:element, :from => :content).name_explicit?.should be_false
    end
  end

  shared_examples_for "DateTime reference" do
    it "should return nil on empty string" do
      @subject.blocks.first.call("  ").should be_nil
    end

    it "should return a time version of the string" do
      @subject.blocks.first.call("12:05pm, September 3rd, 1970").to_s == "1970-09-03T12:05:00+00:00"
    end

    context "when passed an array of values" do
      it "should timify all of them" do
        @subject.blocks.first.call(["12:05pm, September 3rd, 1970", "3:00pm, May 22, 1700"]).map(&:to_s).should == ["1970-09-03T12:05:00+00:00", "1700-05-22T15:00:00+00:00"]
      end
    end
  end

  shared_examples_for "Date reference" do
    it "should return nil on empty string" do
      @subject.blocks.first.call("  ").should be_nil
    end

    it "should return a time version of the string" do
      @subject.blocks.first.call("September 3rd, 1970").to_s == "1970-09-03"
    end

    context "when passed an array of values" do
      it "should timify all of them" do
        @subject.blocks.first.call(["September 3rd, 1970", "1776-07-04"]).map(&:to_s).should == ["1970-09-03", "1776-07-04"]
      end
    end
  end

  it "should unescape xml entities" do
    ROXML::Definition.new(:questions, :as => []).to_ref(RoxmlObject.new).value_in(%{
      <xml>
        <question>&quot;Wickard &amp; Filburn&quot; &gt;</question>
        <question> &lt; McCulloch &amp; Maryland?</question>
      </xml>
    }).should == ["\"Wickard & Filburn\" >", " < McCulloch & Maryland?"]
  end

  it "should unescape utf characters in xml" do
    ROXML::Definition.new(:questions, :as => []).to_ref(RoxmlObject.new).value_in(%{
      <xml>
        <question>ROXML\342\204\242</question>
      </xml>
    }).should == ["ROXML™"]
  end

  describe "attr name" do
    context "when ending with '_at'" do
      context "and without an :as argument" do
        before(:all) do
          @subject = ROXML::Definition.new(:time_at)
        end
        it_should_behave_like "DateTime reference"
      end
    end

    context "when ending with '_on'" do
      context "and without an :as argument" do
        before(:all) do
          @subject = ROXML::Definition.new(:created_on)
        end
        it_should_behave_like "Date reference"
      end
    end
  end

  describe ":as" do
    describe "=> []" do
      it "should means array of texts" do
        opts = ROXML::Definition.new(:authors, :as => [])
        opts.array?.should be_true
        opts.sought_type.should == :text
      end
    end

    describe "=> RoxmlClass" do
      class RoxmlClass
        include ROXML
      end

      it "should store type" do
        opts = ROXML::Definition.new(:name, :as => RoxmlClass)
        opts.sought_type.should == RoxmlClass
      end
    end

    describe "=> NonRoxmlClassWithFromXmlDefined" do
      class OctalInteger
        def self.from_xml(val)
          new(Integer(val.content))
        end
      end

      it "should accept type" do
        opts = ROXML::Definition.new(:name, :as => OctalInteger)
        opts.sought_type.should == OctalInteger
      end
    end

    describe "=> NonRoxmlClass" do
      it "should fail with a warning" do
        proc { ROXML::Definition.new(:authors, :as => Module) }.should raise_error(ArgumentError)
      end
    end

    describe "=> [NonRoxmlClass]" do
      it "should raise" do
        proc { ROXML::Definition.new(:authors, :as => [Module]) }.should raise_error(ArgumentError)
      end
    end

    describe "=> {}" do
      shared_examples_for "hash options declaration" do
        it "should represent a hash" do
          @opts.hash?.should be_true
        end

        it "should have hash definition" do
          {@opts.hash.key.sought_type => @opts.hash.key.name}.should == @hash_args[:key]
          {@opts.hash.value.sought_type => @opts.hash.value.name}.should == @hash_args[:value]
        end

        it "should not represent an array" do
          @opts.array?.should be_false
        end
      end

      describe "hash with attr key and text val" do
        before do
          @opts = ROXML::Definition.new(:attributes, :as => {:key => '@name',
                                                             :value => 'value'})
          @hash_args = {:key => {:attr => 'name'},
                        :value => {:text => 'value'}}
        end

        it_should_behave_like "hash options declaration"
      end

      describe "hash with String class for type" do
        before do
          @opts = ROXML::Definition.new(:attributes, :as => {:key => 'name',
                                                             :value => 'value'})
          @hash_args = {:key => {:text => 'name'}, :value => {:text => 'value'}}
        end

        it_should_behave_like "hash options declaration"
      end

      describe "hash with attr key and content val" do
        before do
          @opts = ROXML::Definition.new(:attributes, :as => {:key => '@name',
                                                             :value => :content})
          @hash_args = {:key => {:attr => 'name'}, :value => {:text => '.'}}
        end

        it_should_behave_like "hash options declaration"
      end

      describe "hash with names as keys and content vals" do
        before do
          @opts = ROXML::Definition.new(:attributes, :as => {:key => :name,
                                                             :value => :content})
          @hash_args = {:key => {:text => '*'}, :value => {:text => '.'}}
        end

        it_should_behave_like "hash options declaration"
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
          @opts.sought_type.should == :text
          @opts.blocks.size.should == 1
        end
      end

      it "should have no blocks without a shorthand" do
        ROXML::Definition.new(:count).blocks.should be_empty
      end

      it "should raise on unknown :as" do
        proc { ROXML::Definition.new(:count, :as => :bogus) }.should raise_error(ArgumentError)
        proc { ROXML::Definition.new(:count, :as => :foat) }.should raise_error(ArgumentError)
      end

      shared_examples_for "block shorthand type declaration" do
        it "should translate nil to nil" do
          @definition.blocks.first.call(nil).should be_nil
        end

        it "should translate empty strings to nil" do
          @definition.blocks.first.call("").should be_nil
          @definition.blocks.first.call(" ").should be_nil
        end
      end

      describe "Integer" do
        before do
          @definition = ROXML::Definition.new(:intvalue, :as => Integer)
        end

        it_should_behave_like "block shorthand type declaration"

        it "should translate text to integers" do
          @definition.blocks.first['3'].should == 3
          @definition.blocks.first['792'].should == 792
        end

        it "should raise on non-integer values" do
          proc { @definition.blocks.first['08'] }.should raise_error(ArgumentError)
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

      describe "Float" do
        before do
          @definition = ROXML::Definition.new(:floatvalue, :as => Float)
        end

        it_should_behave_like "block shorthand type declaration"

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

      describe "BigDecimal" do
        before do
          @definition = ROXML::Definition.new(:decimalvalue, :as => BigDecimal)
        end

        it_should_behave_like "block shorthand type declaration"

        it "should translate text to decimal numbers" do
          @definition.blocks.first['3'].should == BigDecimal("3.0")
          @definition.blocks.first['0.3'].should == BigDecimal("0.3")
        end

        it "should extract what it can, and fall back to 0" do
          @definition.blocks.first['junk 11'].should eql(BigDecimal("0"))
          @definition.blocks.first['11sttf'].should eql(BigDecimal("11.0"))
        end

        context "when passed an array" do
          it "should translate the array elements to integer" do
            @definition.blocks.first.call(["12.1", "328.2"]).should == [BigDecimal("12.1"), BigDecimal("328.2")]
          end
        end
      end

      describe "Fixnum" do
        before do
          @definition = ROXML::Definition.new(:fixnumvalue, :as => Fixnum)
        end

        it_should_behave_like "block shorthand type declaration"

        it "should translate text to integers" do
          @definition.blocks.first['3'].should == 3
          @definition.blocks.first['792'].should == 792
          @definition.blocks.first['08'].should == 8
          @definition.blocks.first['279.23'].should == 279
        end

        it "should extract whatever is possible and fall back to 0" do
          @definition.blocks.first['junk 11'].should eql(0)
          @definition.blocks.first['.?sttf'].should eql(0)
          @definition.blocks.first['11sttf'].should eql(11)
        end

        context "when passed an array" do
          it "should translate the array elements to integer" do
            @definition.blocks.first.call(["792", "12", "328"]).should == [792, 12, 328]
          end
        end
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
        before do
          @subject = ROXML::Definition.new(:datevalue, :as => Date)
        end
        it_should_behave_like "Date reference"
      end

      describe "DateTime" do
        before do
          @subject = ROXML::Definition.new(:datevalue, :as => DateTime)
        end
        it_should_behave_like "DateTime reference"
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
    shared_examples_for "attribute reference" do
      it "should be interpreted as :attr" do
        @opts.sought_type.should == :attr
      end

      it "should strip '@' from name" do
        @opts.name.should == 'attr_name'
      end

      it "should unescape xml entities" do
        @opts.to_ref(RoxmlObject.new).value_in(%{
          <question attr_name="&quot;Wickard &amp; Filburn&quot; &gt; / &lt; McCulloch &amp; Marryland?" />
        }).should == "\"Wickard & Filburn\" > / < McCulloch & Marryland?"
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
        @opts = ROXML::Definition.new(:attr_name, :from => '@attr_name')
      end

      it_should_behave_like "attribute reference"
    end

    describe ":content" do
      it "should be recognized" do
        ROXML::Definition.new(:author).content?.should be_false
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

    shared_examples_for "boolean option" do
      it "should be recognized" do
        ROXML::Definition.new(:author, :from => :content, @option => true).respond_to?(:"#{@option}?")
        ROXML::Definition.new(:author, :from => :content, @option => true).send(:"#{@option}?").should be_true
        ROXML::Definition.new(:author, :from => :content, @option => false).send(:"#{@option}?").should be_false
      end

      it "should default to false" do
        ROXML::Definition.new(:author, :from => :content).send(:"#{@option}?").should be_false
      end
    end

    describe ":required" do
      before do
        @option = :required
      end

      it_should_behave_like "boolean option"

      it "should not be allowed together with :else" do
        proc { ROXML::Definition.new(:author, :from => :content, :required => true, :else => 'Johnny') }.should raise_error(ArgumentError)
        proc { ROXML::Definition.new(:author, :from => :content, :required => false, :else => 'Johnny') }.should_not raise_error
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
