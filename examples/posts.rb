dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require File.join(dir, 'happymapper')

file_contents = File.read(dir + '/../spec/fixtures/posts.xml')

class Post
  include ROXML
  
  attribute :href
  attribute :hash
  attribute :description
  attribute :tag
  attribute :time, :as => DateTime
  attribute :others, :as => Integer
  attribute :extended
end

posts = Post.parse(file_contents)
posts.each { |post| puts post.description, post.href, post.extended, '' }