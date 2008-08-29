require "lib/roxml"

class Book
  include ROXML

  xml_attribute :isbn
  xml_text :title
  xml_text :description, nil, ROXML::TAG_CDATA
  xml_text :author
end

class Author
  include ROXML

  xml_attribute :role
  xml_text :text, nil, ROXML::TEXT_CONTENT
end

class BookWithAuthorTextAttribute
  include ROXML

  xml_attribute :isbn
  xml_text :title
  xml_text :description, nil, ROXML::TAG_CDATA
  xml_object :author, Author
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
  xml_object :contributions, Contributor, ROXML::TAG_ARRAY, "contributions"
end

class BookWithContributors
  include ROXML

  xml_name :book
  xml_attribute :isbn
  xml_text :title
  xml_text :description
  xml_object :contributors, Contributor, ROXML::TAG_ARRAY
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
  xml_object :publisher, Publisher
end

class BookPair
  include ROXML

  xml_attribute :isbn
  xml_text :title
  xml_text :description
  xml_text :author
  xml_object :book, Book
end

class Library
  include ROXML

  xml_text :name
  xml_object :books, BookWithContributions, ROXML::TAG_ARRAY
end

class Person
  include ROXML
  
  xml_text :name, nil, ROXML::TEXT_CONTENT
end
