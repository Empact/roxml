# encoding: utf-8
require_relative './spec_helper'

describe ROXML::Definition do
  describe "#name_explicit?" do
    it "should indicate whether from option is present" do
      expect(ROXML::Definition.new(:element, :from => 'somewhere').name_explicit?).to be_truthy
      expect(ROXML::Definition.new(:element).name_explicit?).to be_falsey
    end

    it "should not consider name proxies as explicit" do
      expect(ROXML::Definition.new(:element, :from => :attr).name_explicit?).to be_falsey
      expect(ROXML::Definition.new(:element, :from => :content).name_explicit?).to be_falsey
    end
  end

  shared_examples_for "DateTime reference" do
    it "should return nil on empty string" do
      expect(@subject.blocks.first.call("  ")).to be_nil
    end

    it "should return a time version of the string" do
      @subject.blocks.first.call("12:05pm, September 3rd, 1970").to_s == "1970-09-03T12:05:00+00:00"
    end

    context "when passed an array of values" do
      it "should timify all of them" do
        expect(@subject.blocks.first.call(["12:05pm, September 3rd, 1970", "3:00pm, May 22, 1700"]).map(&:to_s)).to eq(["1970-09-03T12:05:00+00:00", "1700-05-22T15:00:00+00:00"])
      end
    end
  end

  shared_examples_for "Date reference" do
    it "should return nil on empty string" do
      expect(@subject.blocks.first.call("  ")).to be_nil
    end

    it "should return a time version of the string" do
      @subject.blocks.first.call("September 3rd, 1970").to_s == "1970-09-03"
    end

    context "when passed an array of values" do
      it "should timify all of them" do
        expect(@subject.blocks.first.call(["September 3rd, 1970", "1776-07-04"]).map(&:to_s)).to eq(["1970-09-03", "1776-07-04"])
      end
    end
  end

  it "should unescape xml entities" do
    expect(ROXML::Definition.new(:questions, :as => []).to_ref(RoxmlObject.new).value_in(%{
      <xml>
        <question>&quot;Wickard &amp; Filburn&quot; &gt;</question>
        <question> &lt; McCulloch &amp; Maryland?</question>
      </xml>
    })).to eq(["\"Wickard & Filburn\" >", " < McCulloch & Maryland?"])
  end

  it "should unescape utf characters in xml" do
    expect(ROXML::Definition.new(:questions, :as => []).to_ref(RoxmlObject.new).value_in(%{
      <xml>
        <question>ROXML\342\204\242</question>
      </xml>
    })).to eq(["ROXML™"])
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
        expect(opts.array?).to be_truthy
        expect(opts.sought_type).to eq(:text)
      end
    end

    describe "=> RoxmlClass" do
      class RoxmlClass
        include ROXML
      end

      it "should store type" do
        opts = ROXML::Definition.new(:name, :as => RoxmlClass)
        expect(opts.sought_type).to eq(RoxmlClass)
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
        expect(opts.sought_type).to eq(OctalInteger)
      end
    end

    describe "=> NonRoxmlClass" do
      it "should fail with a warning" do
        expect { ROXML::Definition.new(:authors, :as => Module) }.to raise_error(ArgumentError)
      end
    end

    describe "=> [NonRoxmlClass]" do
      it "should raise" do
        expect { ROXML::Definition.new(:authors, :as => [Module]) }.to raise_error(ArgumentError)
      end
    end

    describe "=> {}" do
      shared_examples_for "hash options declaration" do
        it "should represent a hash" do
          expect(@opts.hash?).to be_truthy
        end

        it "should have hash definition" do
          expect({@opts.hash.key.sought_type => @opts.hash.key.name}).to eq(@hash_args[:key])
          expect({@opts.hash.value.sought_type => @opts.hash.value.name}).to eq(@hash_args[:value])
        end

        it "should not represent an array" do
          expect(@opts.array?).to be_falsey
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
          expect(@opts.array?).to be_truthy
        end

        it "should be normal otherwise" do
          expect(@opts.sought_type).to eq(:text)
          expect(@opts.blocks.size).to eq(1)
        end
      end

      it "should have no blocks without a shorthand" do
        expect(ROXML::Definition.new(:count).blocks).to be_empty
      end

      it "should raise on unknown :as" do
        expect { ROXML::Definition.new(:count, :as => :bogus) }.to raise_error(ArgumentError)
        expect { ROXML::Definition.new(:count, :as => :foat) }.to raise_error(ArgumentError)
      end

      shared_examples_for "block shorthand type declaration" do
        it "should translate nil to nil" do
          expect(@definition.blocks.first.call(nil)).to be_nil
        end

        it "should translate empty strings to nil" do
          expect(@definition.blocks.first.call("")).to be_nil
          expect(@definition.blocks.first.call(" ")).to be_nil
        end
      end

      describe "Integer" do
        before do
          @definition = ROXML::Definition.new(:intvalue, :as => Integer)
        end

        it_should_behave_like "block shorthand type declaration"

        it "should translate text to integers" do
          expect(@definition.blocks.first['3']).to eq(3)
          expect(@definition.blocks.first['792']).to eq(792)
          expect(@definition.blocks.first['08']).to eq(8)
          expect(@definition.blocks.first['279.23']).to eq(279)
        end

        it "should extract whatever is possible and fall back to 0" do
          expect(@definition.blocks.first['junk 11']).to eql(0)
          expect(@definition.blocks.first['.?sttf']).to eql(0)
          expect(@definition.blocks.first['11sttf']).to eql(11)
        end

        context "when passed an array" do
          it "should translate the array elements to integer" do
            expect(@definition.blocks.first.call(["792", "12", "328"])).to eq([792, 12, 328])
          end
        end
      end

      describe "Float" do
        before do
          @definition = ROXML::Definition.new(:floatvalue, :as => Float)
        end

        it_should_behave_like "block shorthand type declaration"

        it "should translate text to float" do
          expect(@definition.blocks.first['3']).to eq(3.0)
          expect(@definition.blocks.first['12.7']).to eq(12.7)
        end

        it "should raise on non-float values" do
          expect { @definition.blocks.first['junk 11.3'] }.to raise_error(ArgumentError)
          expect { @definition.blocks.first['11.1sttf'] }.to raise_error(ArgumentError)
        end

        context "when passed an array" do
          it "should translate the array elements to integer" do
            expect(@definition.blocks.first.call(["792.13", "240", "3.14"])).to eq([792.13, 240.0, 3.14])
          end
        end
      end

      describe "BigDecimal" do
        before do
          @definition = ROXML::Definition.new(:decimalvalue, :as => BigDecimal)
        end

        it_should_behave_like "block shorthand type declaration"

        it "should translate text to decimal numbers" do
          expect(@definition.blocks.first['3']).to eq(BigDecimal.new("3.0"))
          expect(@definition.blocks.first['0.3']).to eq(BigDecimal.new("0.3"))
        end

        # Ruby behavior of BigDecimal changed in 2.4, this test is not valid on older rubies
        if RUBY_VERSION >= "2.4"
          it "should raise on non-decimal values" do
            expect { @definition.blocks.first['junk 11'] }.to raise_error(ArgumentError)
          end
        end

        it "should extract what it can" do
          expect(@definition.blocks.first['11sttf']).to eql(BigDecimal.new("11.0"))
        end

        context "when passed an array" do
          it "should translate the array elements to integer" do
            expect(@definition.blocks.first.call(["12.1", "328.2"])).to eq([BigDecimal.new("12.1"), BigDecimal.new("328.2")])
          end
        end
      end

      describe ":bool" do
        it "should boolify individual values" do
          expect(ROXML::Definition.new(:floatvalue, :as => :bool).blocks.first.call("1")).to be_truthy
          expect(ROXML::Definition.new(:floatvalue, :as => :bool).blocks.first.call("True")).to be_truthy
          expect(ROXML::Definition.new(:floatvalue, :as => :bool).blocks.first.call("Yes")).to be_truthy
        end

        context "when an array is passed in" do
          it "should boolify arrays of values" do
            expect(ROXML::Definition.new(:floatvalue, :as => :bool).blocks.first.call("0")).to be_falsey
            expect(ROXML::Definition.new(:floatvalue, :as => :bool).blocks.first.call("false")).to be_falsey
            expect(ROXML::Definition.new(:floatvalue, :as => :bool).blocks.first.call("nO")).to be_falsey
          end
        end

        context "when no value is detected" do
          it "should return nil" do
            expect(ROXML::Definition.new(:floatvalue, :as => :bool).blocks.first.call("junk")).to be_nil
          end

          context "when a literal block is available" do
            it "should pass the value itself to the block"
          end
        end
      end

      describe "Time" do
        it "should return nil on empty string" do
          expect(ROXML::Definition.new(:floatvalue, :as => Time).blocks.first.call("  ")).to be_nil
        end

        it "should return a time version of the string" do
          expect(ROXML::Definition.new(:datevalue, :as => Time).blocks.first.call("12:31am").min).to eq(31)
        end

        context "when passed an array of values" do
          it "should timify all of them" do
            expect(ROXML::Definition.new(:datevalue, :as => Time).blocks.first.call(["12:31am", "3:00pm", "11:59pm"]).map(&:min)).to eq([31, 0, 59])
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
        expect { ROXML::Definition.new(:count, :as => [Float, Integer]) }.to raise_error(ArgumentError)
      end

      it "should stack block shorthands with explicit blocks" do
        expect(ROXML::Definition.new(:count, :as => Integer) {|val| val.to_i }.blocks.size).to eq(2)
        expect(ROXML::Definition.new(:count, :as => Float) {|val| val.object_id }.blocks.size).to eq(2)
      end
    end
  end

  describe ":from" do
    shared_examples_for "attribute reference" do
      it "should be interpreted as :attr" do
        expect(@opts.sought_type).to eq(:attr)
      end

      it "should strip '@' from name" do
        expect(@opts.name).to eq('attr_name')
      end

      it "should unescape xml entities" do
        expect(@opts.to_ref(RoxmlObject.new).value_in(%{
          <question attr_name="&quot;Wickard &amp; Filburn&quot; &gt; / &lt; McCulloch &amp; Marryland?" />
        })).to eq("\"Wickard & Filburn\" > / < McCulloch & Marryland?")
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
        expect(ROXML::Definition.new(:author).content?).to be_falsey
        expect(ROXML::Definition.new(:author, :from => :content).content?).to eq(true)
      end

      it "should be equivalent to :from => '.'" do
        expect(ROXML::Definition.new(:author, :from => '.').content?).to eq(true)
      end
    end
  end

  describe ":in" do
    context "as xpath" do
      it "should pass through as wrapper" do
        expect(ROXML::Definition.new(:manufacturer, :in => './').wrapper).to eq('./')
      end
    end

    context "as xpath" do
      it "should pass through as wrapper" do
        expect(ROXML::Definition.new(:manufacturer, :in => 'wrapper').wrapper).to eq('wrapper')
      end
    end
  end

  describe "options" do

    shared_examples_for "boolean option" do
      it "should be recognized" do
        ROXML::Definition.new(:author, :from => :content, @option => true).respond_to?(:"#{@option}?")
        expect(ROXML::Definition.new(:author, :from => :content, @option => true).send(:"#{@option}?")).to be_truthy
        expect(ROXML::Definition.new(:author, :from => :content, @option => false).send(:"#{@option}?")).to be_falsey
      end

      it "should default to false" do
        expect(ROXML::Definition.new(:author, :from => :content).send(:"#{@option}?")).to be_falsey
      end
    end

    describe ":required" do
      before do
        @option = :required
      end

      it_should_behave_like "boolean option"

      it "should not be allowed together with :else" do
        expect { ROXML::Definition.new(:author, :from => :content, :required => true, :else => 'Johnny') }.to raise_error(ArgumentError)
        expect { ROXML::Definition.new(:author, :from => :content, :required => false, :else => 'Johnny') }.to_not raise_error
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
