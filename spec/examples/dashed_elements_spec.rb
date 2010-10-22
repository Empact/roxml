require_relative './../spec_helper'
require_relative './../../examples/dashed_elements'

describe GitHub::Commit do
  before do
    @commit = GitHub::Commit.from_xml(xml_for('dashed_elements'))
  end

  it "should extract committed date" do
    @commit.committed_date.should be_an_instance_of(Date)
  end

  it "should extract url" do
    @commit.url.should_not be_empty
  end

  it "should extract id" do
    @commit.id.should_not be_empty
  end
end