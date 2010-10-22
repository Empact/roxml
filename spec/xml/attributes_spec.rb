require_relative './../spec_helper'

describe ROXML::XMLAttributeRef do
  before do
    @xml = ROXML::XML.parse_string %(
<myxml>
  <node name="first" />
  <node name="second" />
  <node name="third" />
</myxml>)
  end

  context "plain vanilla" do
    before do
      @ref = ROXML::XMLAttributeRef.new(OpenStruct.new(:name => 'name', :wrapper => 'node', :array? => false), RoxmlObject.new)
    end

    it "should return one instance" do
      @ref.value_in(@xml).should == "first"
    end
    it "should output one instance"
  end
  
  context "with :as => []" do
    before do
      @ref = ROXML::XMLAttributeRef.new(OpenStruct.new(:name => 'name', :wrapper => 'node', :array? => true), RoxmlObject.new)
    end

    it "should collect all instances" do
      @ref.value_in(@xml).should == ["first", "second", "third"]
    end

    it "should output all instances" do
      xml = ROXML::XML.new_node('myxml')
      @ref.update_xml(xml, ["first", "second", "third"])
      xml.to_s.squeeze(' ').should == @xml.root.to_s.squeeze(' ')
    end
  end
  
  context "when the namespaces are different" do
    before do
      @xml = ROXML::XML.parse_string %(
      <document>
      <myxml xmlns="http://example.com/three" xmlns:one="http://example.com/one" xmlns:two="http://example.com/two">
        <one:node name="first" />
        <two:node name="second" />
        <node name="third" />
      </myxml>
      </document>
      )
    end

    context "with :namespace => '*'" do
      before do
        @ref = ROXML::XMLAttributeRef.new(OpenStruct.new(:name => 'name', :wrapper => 'node', :array? => true, :namespace => '*'), RoxmlObject.new)
      end

      it "should collect all instances" do
        pending "Test bug?"
        @ref.value_in(@xml).should == ["first", "second", "third"]
      end

      it "should output all instances with namespaces" do
        pending "Full namespace write support"
        xml = ROXML::XML.new_node('result')
        @ref.update_xml(xml, ["first", "second", "third"])
        xml.should == @xml.root
      end
    end
  end
end