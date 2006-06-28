require "lib/roxml"

class RoxmlMockObject
  include ROXML
end

class Book < RoxmlMockObject
    xml_attribute :isbn
    xml_text :title
    xml_text :description, nil, ROXML::TAG_CDATA
    xml_text :author
end

class Contributor < RoxmlMockObject
  xml_attribute :role
  xml_text :name
end

class BookWithContributions < RoxmlMockObject
    xml_name :book
    xml_attribute :isbn
    xml_text :title
    xml_text :description
    xml_object :contributions, Contributor, ROXML::TAG_ARRAY, "contributions"
end

class BookWithContributors < RoxmlMockObject
    xml_name :book
    xml_attribute :isbn
    xml_text :title
    xml_text :description
    xml_object :contributors, Contributor, ROXML::TAG_ARRAY
end

class Publisher < RoxmlMockObject
  xml_text :name
end

class BookWithPublisher < RoxmlMockObject
    xml_name :book
    xml_attribute :isbn
    xml_text :title
    xml_text :description
    xml_object :publisher, Publisher
end

class BookPair < RoxmlMockObject
    xml_attribute :isbn
    xml_text :title
    xml_text :description
    xml_text :author
    xml_object :book, Book
end

class Library < RoxmlMockObject
  xml_text :name
  xml_object :books, BookWithContributions, ROXML::TAG_ARRAY
end

