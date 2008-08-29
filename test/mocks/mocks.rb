require "lib/roxml"

class Book
  include ROXML

  xml_attribute :isbn
  xml_text :title
  xml_text :description, :as => ROXML::TAG_CDATA
  xml_text :author
end

class Author
  include ROXML

  xml_attribute :role
  xml_text :text, :as => ROXML::TEXT_CONTENT
end

class BookWithAuthorTextAttribute
  include ROXML

  xml_attribute :isbn
  xml_text :title
  xml_text :description, :as => ROXML::TAG_CDATA
  xml_object :author, :of => Author
end

class Contributor
  include ROXML

  xml_attribute :role
  xml_text :name
end

class BookWithContributions
  include ROXML

  xml_name :book
  xml_attribute :isbn
  xml_text :title
  xml_text :description
  xml_object :contributions, :of => Contributor, :as => ROXML::TAG_ARRAY, :in => "contributions"
end

class BookWithContributors
  include ROXML

  xml_name :book
  xml_attribute :isbn
  xml_text :title
  xml_text :description
  xml_object :contributors, :of => Contributor, :as => ROXML::TAG_ARRAY
end

class Publisher
  include ROXML

  xml_text :name
end

class BookWithPublisher
  include ROXML

  xml_name :book
  xml_attribute :isbn
  xml_text :title
  xml_text :description
  xml_object :publisher, :of => Publisher
end

class BookPair
  include ROXML

  xml_attribute :isbn
  xml_text :title
  xml_text :description
  xml_text :author
  xml_object :book, :of => Book
end

class Library
  include ROXML

  xml_text :name
  xml_object :books, :of => BookWithContributions, :as => ROXML::TAG_ARRAY
end

class Person
  include ROXML
  
  xml_text :name, :as => ROXML::TEXT_CONTENT
end
