require 'spec_helper'
require_relative './../../examples/dashed_elements'

describe GitHub::Commit do
  before do
    @commit = GitHub::Commit.from_xml(xml_for('dashed_elements'))
  end

  it "should extract committed date" do
    expect(@commit.committed_date).to be_an_instance_of(Date)
  end

  it "should extract url" do
    expect(@commit.url).to_not be_empty
  end

  it "should extract id" do
    expect(@commit.id).to_not be_empty
  end
end