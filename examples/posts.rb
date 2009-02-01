#!/usr/bin/env ruby
require File.expand_path(File.dirname(__FILE__) + '/../spec/spec_helper')

class Post
  include ROXML
  
  xml_reader :href, :attr
  xml_reader :hash, :attr
  xml_reader :description, :attr
  xml_reader :tag, :attr
  xml_reader :time, :attr, :as => DateTime
  xml_reader :others, :attr, :as => Integer
  xml_reader :extended, :attr
end

class Posts
  include ROXML

  xml_reader :posts, [Post]
end

unless defined?(Spec)
  posts = Posts.from_xml(xml_for('posts'))
  posts.posts.each do |post|
    puts post.description, post.href, post.extended, ''
  end
end