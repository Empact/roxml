require_relative './../spec_helper.rb'

describe ROXML::XML do
  it "should escape invalid characters on output to text node" do
    node = ROXML::XML.new_node("entities")
    ROXML::XML.set_content(node, " < > ' \" & ")
    expect(node.to_s).to eq("<entities> &lt; &gt; ' \" &amp; </entities>")
  end

  it "should esape invalid characters for attribute name" do
    node = ROXML::XML.new_node("attr_holder")
    ROXML::XML.set_attribute(node, "entities", "\"'<>&")
    expect(node.to_s).to eq(%{<attr_holder entities="&quot;'&lt;&gt;&amp;"/>})
  end
end
