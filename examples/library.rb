class Publisher
  include ROXML

  xml_accessor :name
  
  def initialize(name = nil)
    @name = name
  end
  
  def ==(other)
    name == other.name
  end
  
  # other important functionality
end

class Novel
  include ROXML

  xml_accessor :isbn, :from => "@ISBN" # attribute with name 'ISBN'
  xml_accessor :title
  xml_accessor :description, :cdata => true  # text node with cdata protection
  xml_accessor :author
  xml_accessor :publisher, :as => Publisher # singular object reference for illustrative purposes.
  
  def ==(other)
    self.class.roxml_attrs.map(&:accessor).all? {|attr| send(attr) == other.send(attr) }
  end
end

class Library
  include ROXML

  xml_accessor :name, :from => "NAME", :cdata => true
  xml_accessor :novels, :as => [Novel] # by default roxml searches for books for in <novel> children, then, if none are present, in ./novels/novel children
  
  def ==(other)
    name == other.name && novels == other.novels
  end
end
