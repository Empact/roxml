require_relative './../spec_helper'
require_relative './../../examples/posts'

describe Post do
  before do
    @posts = Posts.from_xml(xml_for('posts')).posts
  end

  it "should extract description" do
    @posts.each {|post| post.description.should_not be_empty }
  end

  it "should extract href" do
    @posts.each {|post| post.href.should_not be_empty }
  end

  it "should extract extended" do
    @posts.each {|post| post.extended.should_not be_empty }
  end

  it "should extract time" do
    @posts.each {|post| post.created_at.should be_an_instance_of(DateTime) }
  end
end