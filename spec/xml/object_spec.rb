require_relative './../spec_helper'

describe ROXML::XMLObjectRef do
  class SubObject
    include ROXML

    xml_reader :value, :from => :attr

    def initialize(value = nil)
      @value = value
    end
  end

  before do
    @xml = ROXML::XML.parse_string %(
<myxml>
  <node>
    <name value="first" />
    <name value="second" />
    <name value="third" />
  </node>
</myxml>)
  end

  context "plain vanilla" do
    before do
      @ref = ROXML::XMLObjectRef.new(OpenStruct.new(:name => 'name', :wrapper => 'node', :array? => false, :sought_type => SubObject), RoxmlObject.new)
    end

    it "should return one instance" do
      @ref.value_in(@xml).value.should == "first"
    end
    it "should output one instance"
  end
  
  context "with :as => []" do
    before do
      @ref = ROXML::XMLObjectRef.new(OpenStruct.new(:name => 'name', :wrapper => 'node', :array? => true, :sought_type => SubObject), RoxmlObject.new)
    end

    it "should collect all instances" do
      @ref.value_in(@xml).map(&:value).should == ["first", "second", "third"]
    end

    it "should output all instances" do
      xml = ROXML::XML.new_node('myxml')
      @ref.update_xml(xml, ["first", "second", "third"].map {|value| SubObject.new(value) })
      xml.to_s.squeeze(' ').should == @xml.root.to_s.squeeze(' ')
    end
  end
  
  context "when the namespaces are different" do
    before do
      @xml = ROXML::XML.parse_string %(
      <myxml xmlns="http://example.com/three" xmlns:one="http://example.com/one" xmlns:two="http://example.com/two">
        <node>
          <one:name>first</one:name>
          <two:name>second</two:name>
          <name>third</name>
        </node>
      </myxml>)
    end

    context "with :namespace => '*'" do
      before do
        @ref = ROXML::XMLObjectRef.new(OpenStruct.new(:name => 'name', :wrapper => 'node', :array? => true, :namespace => '*', :sought_type => SubObject), RoxmlObject.new)
      end

      it "should collect all instances" do
        pending "Test bug?"
        @ref.value_in(@xml).map(&:value).should == ["first", "second", "third"]
      end

      it "should output all instances with namespaces" do
        pending "Full namespace write support"
        xml = ROXML::XML.new_node('myxml')
        @ref.update_xml(xml, ["first", "second", "third"].map {|value| SubObject.new(value) })
        xml.should == @xml.root
      end
    end
  end
end