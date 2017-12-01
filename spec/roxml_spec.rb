require_relative './spec_helper'

describe ROXML do
  describe "::VERSION" do
    it "should be equal to the VERSION file contents" do
      expect(ROXML::VERSION).to eq(File.read('VERSION'))
    end
  end

  describe "#from_xml" do
    shared_examples_for "from_xml call" do
      it "should fetch values" do
        book = BookWithContributors.from_xml(@path)
        expect(book.title).to eq("Programming Ruby - 2nd Edition")
        expect(book.contributors.map(&:name)).to eq(["David Thomas","Andrew Hunt","Chad Fowler"])
      end
    end

    context "called with PathName" do
      before do
        @path = Pathname.new(fixture_path(:book_with_contributors))
      end
      it_should_behave_like "from_xml call"
    end

    context "called with File" do
      before do
        @path = File.new(fixture_path(:book_with_contributors))
      end
      it_should_behave_like "from_xml call"
    end

    context "called with URI" do
      before do
        require 'uri'
        @path = URI.parse("file://#{File.expand_path(File.expand_path(fixture_path(:book_with_contributors)))}")
      end
      it_should_behave_like "from_xml call"
    end
  end
end

describe ROXML, "#xml" do
  class DescriptionReadonly
    include ROXML

    xml_reader :writable, :from => :content
    xml_reader :readonly, :from => :content, :frozen => true
  end

  class Contributor
    include ROXML

    xml_reader :role, :from => :attr
    xml_reader :name
  end

  class BookWithContributions
    include ROXML

    xml_name :book
    xml_reader :isbn, :from => :attr
    xml_reader :title
    xml_reader :description, :as => DescriptionReadonly
    xml_reader :contributions, :as => [Contributor], :from => 'contributor', :in => "contributions"
  end

  class BookWithContributionsReadonly
    include ROXML

    xml_name :book
    xml_reader :isbn, :from => :attr, :frozen => true
    xml_reader :title, :frozen => true
    xml_reader :description, :as => DescriptionReadonly, :frozen => true
    xml_reader :contributions, :as => [Contributor], :from => 'contributor', :in => "contributions", :frozen => true
  end

  before do
    @writable = BookWithContributions.from_xml(fixture(:book_with_contributions))
    @readonly = BookWithContributionsReadonly.from_xml(fixture(:book_with_contributions))
  end

  it "should raise on duplicate accessor name" do
    expect do
      Class.new do
        include ROXML

        xml_reader :id
        xml_accessor :id
      end
    end.to raise_error(RuntimeError)
  end

  class OctalInteger
    def self.from_xml(val)
      new(Integer(val.content))
    end

    def initialize(value)
      @val = value
    end

    def ==(other)
      @val == other
    end

    def to_xml
      sprintf("%#o", @val)
    end
  end

  describe "overriding output" do
    class BookWithOctalPages
      include ROXML

      xml_accessor :pages_with_as, :as => Integer, :to_xml => proc {|val| sprintf("%#o", val) }, :required => true
      xml_accessor :pages_with_type, :as => OctalInteger, :required => true
    end

    #      to_xml_test :book_with_octal_pages

    describe "with :to_xml option" do
      it "should output with to_xml filtering"
    end

    describe "with #to_xml on the object" do
      it "should output with to_xml filtering"
    end
  end

  describe "overriding input" do
    before do
      @book_with_octal_pages_xml = %{
        <book>
          <pages>0357</pages>
        </book>
      }

      @expected_pages = 239
    end

    describe "with #from_xml defined on the object" do
      class BookWithOctalPagesType
        include ROXML

        xml_accessor :pages, :as => OctalInteger, :required => true
      end

      it "should apply filtering on input" do
        book = BookWithOctalPagesType.from_xml(@book_with_octal_pages_xml)
        expect(book.pages).to eq(@expected_pages)
      end
    end
  end

  describe "attribute reference" do
    before do
      @frozen = @readonly.isbn
      @unfrozen = @writable.isbn
    end

    it_should_behave_like "freezable xml reference"
  end

  describe "text reference" do
    before do
      @frozen = @readonly.title
      @unfrozen = @writable.title
    end

    it_should_behave_like "freezable xml reference"
  end

  describe "object reference" do
    before do
      @frozen = @readonly.description
      @unfrozen = @writable.description
    end

    it_should_behave_like "freezable xml reference"

    describe "indirect reference via an object" do
      it "does not inherit the frozen status from its parent" do
        expect(@frozen.writable.frozen?).to be_falsey
        expect(@frozen.readonly.frozen?).to be_truthy

        expect(@unfrozen.writable.frozen?).to be_falsey
        expect(@unfrozen.readonly.frozen?).to be_truthy
      end
    end
  end

  describe "array reference" do
    before do
      @frozen = @readonly.contributions
      @unfrozen = @writable.contributions
    end

    it_should_behave_like "freezable xml reference"

    it "should apply :frozen to the constituent elements" do
      expect(@frozen.all?(&:frozen?)).to be_truthy
      expect(@unfrozen.any?(&:frozen?)).to be_falsey
    end

    context "no elements are present in root, no :in is specified" do
      class BookWithContributors
        include ROXML

        xml_name :book
        xml_reader :isbn, :from => :attr
        xml_reader :title
        xml_reader :description
        xml_reader :contributors, :as => [Contributor]
      end

      it "should look for elements :in the plural of name" do
        book = BookWithContributors.from_xml(%{
          <book isbn="0974514055">
            <contributors>
              <contributor role="author"><name>David Thomas</name></contributor>
              <contributor role="supporting author"><name>Andrew Hunt</name></contributor>
              <contributor role="supporting author"><name>Chad Fowler</name></contributor>
            </contributors>
          </book>
        })
        expect(book.contributors.map(&:name).sort).to eq(["David Thomas","Andrew Hunt","Chad Fowler"].sort)
      end
    end
  end

  describe "hash reference" do
    class DictionaryOfGuardedNames
      include ROXML

      xml_name :dictionary
      xml_reader :definitions, :as => {:key => :name,
                                :value => :content}, :in => :definitions
    end

    class DictionaryOfGuardedNamesReadonly
      include ROXML

      xml_name :dictionary
      xml_reader :definitions, :as => {:key => :name,
                                :value => :content}, :in => :definitions, :frozen => true
    end

    before do
      @frozen = DictionaryOfGuardedNamesReadonly.from_xml(fixture(:dictionary_of_guarded_names)).definitions
      @unfrozen = DictionaryOfGuardedNames.from_xml(fixture(:dictionary_of_guarded_names)).definitions
    end

    it_should_behave_like "freezable xml reference"

    it "should have frozen keys, as with all hashes" do
      expect(@frozen.keys.all?(&:frozen?)).to be_truthy
      expect(@unfrozen.keys.all?(&:frozen?)).to be_truthy
    end

    it "should apply :frozen to the constituent values" do
      expect(@frozen.values.all?(&:frozen?)).to be_truthy
      expect(@unfrozen.values.any?(&:frozen?)).to be_falsey
    end
  end
end

describe ROXML, "inheritance" do
  class Book
    include ROXML

    xml_accessor :isbn, :from => '@ISBN'
    xml_reader :title
    xml_reader :description, :cdata => true
    xml_reader :author
    xml_accessor :pages, :from => 'pagecount', :as => Integer
  end

  class Measurement
    include ROXML

    xml_reader :units, :from => :attr
    xml_reader :value, :from => :content, :as => Float

    def initialize(value = 0, units = 'pixels')
      @value = Float(value)
      @units = units.to_s
      normalize_hundredths
    end

    def to_s
      "#{value} #{units}"
    end

    def ==(other)
      other.units == @units && other.value == @value
    end

  private
    def after_parse
      normalize_hundredths
    end

    def normalize_hundredths
      if @units.starts_with? 'hundredths-'
        @value /= 100
        @units = @units.split('hundredths-')[1]
      end
    end
  end

  class InheritedBookWithDepth < Book
    xml_reader :depth, :as => Measurement
  end

  before do
    @book_xml =  %{
      <book ISBN="0201710897">
        <title>The PickAxe</title>
        <description><![CDATA[Probably the best Ruby book out there]]></description>
        <author>David Thomas, Andrew Hunt, Dave Thomas</author>
        <depth units="hundredths-meters">1130</depth>
        <publisher>Pragmattic Programmers</publisher>
      </book>
    }

    @parent = Book.from_xml(@book_xml)
    @child = InheritedBookWithDepth.from_xml(@book_xml)
  end

  describe "parent" do
    it "should include its attributes" do
      expect(@child.isbn).to eq("0201710897")
      expect(@child.title).to eq("The PickAxe")
      expect(@child.description).to eq("Probably the best Ruby book out there")
      expect(@child.author).to eq('David Thomas, Andrew Hunt, Dave Thomas')
      expect(@child.pages).to eq(nil)
    end
    
    it "should not include its child's attributes" do
      expect(@parent).to_not respond_to(:depth)
    end
  end
  
  describe "child" do
    it "should include its parent's attributes" do
      expect(@child.isbn).to eq(@parent.isbn)
      expect(@child.title).to eq(@parent.title)
      expect(@child.description).to eq(@parent.description)
      expect(@child.author).to eq(@parent.author)
      expect(@child.pages).to eq(@parent.pages)
    end

    it "should include its attributes" do
      expect(@child.depth.to_s).to eq('11.3 meters')
    end

    it "should include parent's attributes added after declaration" do
      Book.class_eval do
        xml_reader :publisher, :required => true
      end

      book = InheritedBookWithDepth.from_xml(@book_xml)
      expect(book.publisher).to eq("Pragmattic Programmers")
    end
  end
end
