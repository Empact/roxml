require File.dirname(__FILE__) + '/spec_helper.rb'

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
    xml_reader :description, DescriptionReadonly
    xml_reader :contributions, [Contributor], :from => 'contributor', :in => "contributions"
  end

  class BookWithContributionsReadonly
    include ROXML

    xml_name :book
    xml_reader :isbn, :from => :attr, :frozen => true
    xml_reader :title, :frozen => true
    xml_reader :description, DescriptionReadonly, :frozen => true
    xml_reader :contributions, [Contributor], :from => 'contributor', :in => "contributions", :frozen => true
  end

  before do
    @writable = BookWithContributions.from_xml(fixture(:book_with_contributions))
    @readonly = BookWithContributionsReadonly.from_xml(fixture(:book_with_contributions))
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
        @frozen.writable.frozen?.should be_false
        @frozen.readonly.frozen?.should be_true

        @unfrozen.writable.frozen?.should be_false
        @unfrozen.readonly.frozen?.should be_true
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
      @frozen.all?(&:frozen?).should be_true
      @unfrozen.any?(&:frozen?).should be_false
    end

    context "no elements are present in root, no :in is specified" do
      class BookWithContributors
        include ROXML

        xml_name :book
        xml_reader :isbn, :from => :attr
        xml_reader :title
        xml_reader :description
        xml_reader :contributors, [Contributor]
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
        book.contributors.map(&:name).sort.should == ["David Thomas","Andrew Hunt","Chad Fowler"].sort
      end
    end
  end

  describe "hash reference" do
    class DictionaryOfGuardedNames
      include ROXML

      xml_name :dictionary
      xml_reader :definitions, {:key => :name,
                                :value => :content}, :in => :definitions
    end

    class DictionaryOfGuardedNamesReadonly
      include ROXML

      xml_name :dictionary
      xml_reader :definitions, {:key => :name,
                                :value => :content}, :in => :definitions, :frozen => true
    end

    before do
      @frozen = DictionaryOfGuardedNamesReadonly.from_xml(fixture(:dictionary_of_guarded_names)).definitions
      @unfrozen = DictionaryOfGuardedNames.from_xml(fixture(:dictionary_of_guarded_names)).definitions
    end

    it_should_behave_like "freezable xml reference"

    it "should have frozen keys, as with all hashes" do
      @frozen.keys.all?(&:frozen?).should be_true
      @unfrozen.keys.all?(&:frozen?).should be_true
    end

    it "should apply :frozen to the constituent values" do
      @frozen.values.all?(&:frozen?).should be_true
      @unfrozen.values.any?(&:frozen?).should be_false
    end
  end
end