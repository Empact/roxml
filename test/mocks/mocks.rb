require "lib/roxml"

class Book
  include ROXML

  xml_accessor :isbn, :attr => 'ISBN'
  xml_reader :title
  xml_reader :description, :as => :cdata
  xml_reader :author
  xml_accessor :pages, :text => 'pagecount' do |val|
    Integer(val)
  end
end

class BookWithAttrFrom
  include ROXML

  xml_accessor :isbn, :attr, :from => 'ISBN'
end

class Measurement
  include ROXML

  xml_reader :units, :attr
  xml_reader :value, :content
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

  xml_reader :isbn, :attr => 'ISBN'
  xml_reader :title
  xml_reader :description, :as => :cdata
  xml_reader :author
  xml_reader :depth, Measurement
end

class InheritedBookWithDepth < Book
  xml_reader :depth, Measurement
end

class Author
  include ROXML

  xml_reader :role, :attr
  xml_reader :text, :content
end

class BookWithAuthors
  include ROXML

  xml_name :book
  xml_reader :isbn, :attr, :from => 'ISBN'
  xml_reader :title
  xml_reader :description, :as => :cdata
  xml_reader :authors, :as => :array
end

class BookWithAuthorTextAttribute
  include ROXML

  xml_name :book
  xml_reader :isbn, :attr, :from => 'ISBN'
  xml_reader :title
  xml_reader :description, :as => :cdata
  xml_reader :author, Author
end

class Contributor
  include ROXML

  xml_reader :role, :attr
  xml_reader :name
end

class BookWithContributions
  include ROXML

  xml_name :book
  xml_reader :isbn, :attr
  xml_reader :title
  xml_reader :description
  xml_reader :contributions, [Contributor], :from => 'contributor', :in => "contributions"
end

class BookWithContributors
  include ROXML

  xml_name :book
  xml_reader :isbn, :attr
  xml_reader :title
  xml_reader :description
  xml_reader :contributors, Contributor, :as => :array
end

class NamelessBook
  include ROXML

  xml_reader :isbn, :attr
  xml_reader :title
  xml_reader :description
  xml_reader :contributors, Contributor, :as => :array
end

class Publisher
  include ROXML

  xml_reader :name
end

class BookWithPublisher
  include ROXML

  xml_reader :book
  xml_reader :isbn, :attr
  xml_reader :title
  xml_reader :description
  xml_reader :publisher, Publisher
end

class BookPair
  include ROXML

  xml_reader :isbn, :attr
  xml_reader :title
  xml_reader :description
  xml_reader :author
  xml_reader :book, Book
end

class Library
  include ROXML

  xml_reader :name
  xml_reader :books, BookWithContributions, :as => :array
end

class UppercaseLibrary
  include ROXML

  xml_name :library
  xml_reader :name, :from => 'NAME'
  xml_reader :books, [BookWithContributions], :from => 'BOOK'
end

class LibraryWithBooksOfUnderivableName
  include ROXML

  xml :name, true
  xml_reader :novels, NamelessBook, :as => :array
end

class NodeWithNameConflicts
  include ROXML

  xml_name :node
  xml_reader :content
  xml_reader :name
end

class NodeWithAttrNameConflicts
  include ROXML

  xml_name :node
  xml_reader :content, :attr => :content
  xml_reader :name, :attr => :name
end

class Person
  include ROXML

  xml_reader :age, :attr, :else => 21
  xml_accessor :name, :content, :else => 'Unknown'
end

class PersonWithMother
  include ROXML

  xml_name :person
  xml_reader :name
  xml_reader :mother, PersonWithMother
end

class PersonWithGuardedMother
  include ROXML

  xml_name :person
  xml_reader :name
  xml_reader :mother, PersonWithGuardedMother, :from => :person, :in => :mother
end

class PersonWithMotherOrMissing
  include ROXML

  xml_reader :age, :attr, :else => 21
  xml_reader :name, :else => 'Anonymous'
  xml_reader :mother, PersonWithMotherOrMissing, :else => Person.new
end