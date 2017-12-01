require 'spec_helper'
require_relative './../../examples/posts'

describe Post do
  before do
    @posts = Posts.from_xml(xml_for('posts')).posts
  end

  it "should extract description" do
    @posts.each {|post| expect(post.description).to_not be_empty }
  end

  it "should extract href" do
    @posts.each {|post| expect(post.href).to_not be_empty }
  end

  it "should extract extended" do
    @posts.each {|post| expect(post.extended).to_not be_empty }
  end

  it "should extract time" do
    @posts.each {|post| expect(post.created_at).to be_an_instance_of(DateTime) }
  end
end