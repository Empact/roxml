require File.join(File.dirname(__FILE__), '../lib/roxml')

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