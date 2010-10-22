require_relative "./../../lib/roxml"

class Muffins
  include ROXML

  xml_reader(:count, :from => 'bakers_dozens') {|val| val.to_i * 13 }
end

class MuffinsWithStackedBlocks
  include ROXML

  xml_reader(:count, :from => 'bakers_dozens', :as => Integer) {|val| val * 13 }
end

class Numerology
  include ROXML

  xml_reader :predictions, :as => {:key => '@number', :value => '@meaning'} do |k, v|
    [Integer(k), v]
  end
end

class Contributor
  include ROXML

  xml_reader :role, :from => :attr
  xml_reader :name
end

class WriteableContributor
  include ROXML

  xml_accessor :role, :from => :attr
  xml_accessor :name
end

class Book
  include ROXML

  xml_accessor :isbn, :from => '@ISBN'
  xml_reader :title
  xml_reader :description, :cdata => true
  xml_reader :author
  xml_accessor :pages, :from => 'pagecount', :as => Integer
end

class BookWithRequired
  include ROXML

  xml_accessor :isbn, :from => '@ISBN', :required => true
  xml_reader :title, :required => true
  xml_reader :contributors, :as => [Contributor], :in => 'contributor_array', :required => true
  xml_reader :contributor_hash, :as => {:key => '@role', :value => '@name'},
                                :from => 'contributor', :in => 'contributor_hash', :required => true
end

class BookWithAttrFrom
  include ROXML

  xml_accessor :isbn, :from => '@ISBN'
end

class BookWithWrappedAttr
  include ROXML

  xml_name :book
  xml_accessor :isbn, :from => '@ISBN', :in => 'ids'
end

class Measurement
  include ROXML

  xml_reader :units, :from => :attr
  xml_reader :value, :from => :content, :as => Float

  def initialize(value = 0, units = 'pixels')
    @value = Float(value)
    @units = units.to_s
    normalize_hundredths
  end

  def to_s
    "#{value} #{units}"
  end

  def ==(other)
    other.units == @units && other.value == @value
  end

private
  def after_parse
    normalize_hundredths
  end

  def normalize_hundredths
    if @units.starts_with? 'hundredths-'
      @value /= 100
      @units = @units.split('hundredths-')[1]
    end
  end
end

class BookWithDepth
  include ROXML

  xml_reader :isbn, :from => '@ISBN'
  xml_reader :title
  xml_reader :description, :cdata => true
  xml_reader :author
  xml_reader :depth, :as => Measurement
end

class Author
  include ROXML

  xml_reader :role, :from => :attr
  xml_reader :text, :from => :content
end

class BookWithAuthors
  include ROXML

  xml_name :book
  xml_reader :isbn, :from => '@ISBN'
  xml_reader :title
  xml_reader :description, :cdata => true
  xml_reader :authors, :as => []
end

class BookWithAuthorTextAttribute
  include ROXML

  xml_name :book
  xml_reader :isbn, :from => '@ISBN'
  xml_reader :title
  xml_reader :description, :cdata => true
  xml_reader :author, :as => Author
end

class BookWithContributions
  include ROXML

  xml_name :book
  xml_reader :isbn, :from => :attr
  xml_reader :title
  xml_reader :description
  xml_reader :contributions, :as => [Contributor], :from => 'contributor', :in => "contributions"
end

class BookWithContributors
  include ROXML

  xml_name :book
  xml_reader :isbn, :from => :attr
  xml_reader :title
  xml_reader :description
  xml_reader :contributors, :as => [Contributor]
end

class WriteableBookWithContributors
  include ROXML

  xml_name :book
  xml_accessor :isbn, :from => :attr
  xml_accessor :title
  xml_accessor :description
  xml_accessor :contributors, :as => [Contributor]
end

class NamelessBook
  include ROXML

  xml_reader :isbn, :from => :attr
  xml_reader :title
  xml_reader :description
  xml_reader :contributors, :as => [Contributor]
end

class Publisher
  include ROXML

  xml_reader :name
end

class BookWithPublisher
  include ROXML

  xml_reader :book
  xml_reader :isbn, :from => :attr
  xml_reader :title
  xml_reader :description
  xml_reader :publisher, :as => Publisher
end

class BookPair
  include ROXML

  xml_reader :isbn, :from => :attr
  xml_reader :title
  xml_reader :description
  xml_reader :author
  xml_reader :book, :as => Book
end

class Library
  include ROXML

  xml_reader :name
  xml_reader :books, :as => [BookWithContributions]
end

class UppercaseLibrary
  include ROXML

  xml_name :library
  xml_reader :name, :from => 'NAME'
  xml_reader :books, :as => [BookWithContributions], :from => 'BOOK'
end

class LibraryWithBooksOfUnderivableName
  include ROXML

  xml_accessor :name
  xml_reader :novels, :as => [NamelessBook]
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
  xml_reader :content, :from => '@content'
  xml_reader :name, :from => '@name'
end

class Person
  include ROXML

  xml_accessor :age, :from => :attr, :else => 21
  xml_accessor :name, :from => :content, :else => 'Unknown'

  def self.blank
    new.tap do |instance|
      instance.age = 21
      instance.name = 'Unknown'
    end
  end
end

class PersonWithMother
  include ROXML

  xml_name :person
  xml_reader :name
  xml_reader :mother, :as => PersonWithMother, :from => 'mother'
end

class PersonWithGuardedMother
  include ROXML

  xml_name :person
  xml_reader :name
  xml_reader :mother, :as => PersonWithGuardedMother, :from => :person, :in => :mother
end

class PersonWithMotherOrMissing
  include ROXML

  xml_reader :age, :from => :attr, :else => 21
  xml_reader :name, :else => 'Anonymous'
  xml_reader :mother,:as => PersonWithMotherOrMissing, :else => Person.blank
end