require "lib/roxml"

class Book
  include ROXML

  xml_attribute :isbn, :from => 'ISBN'
  xml_text :title
  xml_text :description, :as => :cdata
  xml_text :author
end

class Measurement
  include ROXML

  xml_attribute :units
  xml_text :value, :as => :text_content
  xml_construct :value, :units

  def initialize(value, units = 'pixels')
    @value = Float(value)
    @units = units.to_s
    if @units.starts_with? 'hundredths-'
      @value /= 100
      @units = @units.split('hundredths-')[1]
    end
  end

  def ==(other)
    other.units == @units && other.value == @value
  end
end

class BookWithDepth
  include ROXML

  xml_attribute :isbn, :from => 'ISBN'
  xml_text :title
  xml_text :description, :as => :cdata
  xml_text :author
  xml_object :depth, Measurement
end

class InheritedBookWithDepth < Book
  xml_object :depth, Measurement
end

class Author
  include ROXML

  xml_attribute :role
  xml_text :text, :as => :text_content
end

class BookWithAuthors
  include ROXML

  xml_attribute :isbn
  xml_text :title
  xml_text :description, :as => :cdata
  xml_text :authors, :as => :array, :from => 'author'
end

class BookWithAuthorTextAttribute
  include ROXML

  xml_attribute :isbn
  xml_text :title
  xml_text :description, :as => :cdata
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
  xml_object :contributions, Contributor, :as => :array, :in => "contributions"
end

class BookWithContributors
  include ROXML

  xml_name :book
  xml_attribute :isbn
  xml_text :title
  xml_text :description
  xml_object :contributors, Contributor, :as => :array
end

class NamelessBook
  include ROXML

  xml_attribute :isbn
  xml_text :title
  xml_text :description
  xml_object :contributors, Contributor, :as => :array
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
  xml_object :books, BookWithContributions, :as => :array
end

class UppercaseLibrary
  include ROXML

  xml_name :library
  xml_text :name, :from => 'NAME'
  xml_object :books, BookWithContributions, :as => :array, :from => 'BOOK'
end

class LibraryWithBooksOfUnderivableName
  include ROXML

  xml_text :name
  xml_object :novels, NamelessBook, :as => :array
end

class Person
  include ROXML

  xml_text :name, :as => :text_content
end

class PersonWithMother
  include ROXML

  xml_text :name
  xml_object :mother, PersonWithMother
end

class PersonWithGuardedMother
  include ROXML

  xml_text :name
  xml_object :mother, PersonWithGuardedMother, :from => :person, :in => :mother
end
