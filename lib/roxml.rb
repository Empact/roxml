require 'rubygems'
require 'extensions/enumerable'
require 'extensions/array'
require 'activesupport'

%w(array string options xml).each do |file|
  require File.join(File.dirname(__FILE__), 'roxml', file)
end

module ROXML
  # Option that declares that an XML text element's value should be
  # wrapped in a CDATA section.
  TAG_CDATA = :cdata

  # Option that declares an accessor as an array (referencing "many"
  # items).
  TAG_ARRAY = :array

  # Option that declares an xml_text annotation to define the text
  # content of the container tag
  TEXT_CONTENT = :text_content

  # This class defines the annotation methods that are mixed into your
  # Ruby classes for XML mapping information and behavior.
  #
  # See xml_name, xml_text, xml_attribute and xml_object for available
  # annotations.
  #
  module ROXML_Class
    #
    # Creates a new Ruby object from XML using mapping information
    # annotated in the class.
    #
    # The input data is either an XML::Node or a String representing
    # the XML document.
    #
    # Example
    #  book = Book.parse(File.read("book.xml"))
    # or
    #  book = Book.parse("<book><name>Beyond Java</name></book>")
    #
    def parse(data)
      xml = (data.kind_of?(XML::Node) ? data : XML::Parser.string(data).parse.root)

      unless xml_construction_args.empty?
        args = xml_construction_args.map do |arg|
           tag_refs.find {|ref| ref.name == arg.to_s }
        end.map {|ref| ref.value(xml) }
        new(*args)
      else
        returning allocate do |inst|
          tag_refs.each do |ref|
            ref.populate(xml, inst)
          end
        end
      end
    end

    # Sets the name of the XML element that represents this class. Use this
    # to override the default lowercase class name.
    #
    # Example:
    #  class BookWithPublisher
    #   xml_name :book
    #  end
    #
    # Without the xml_name annotation, the XML mapped tag would have been "bookwithpublisher".
    #
    def xml_name(name)
      @tag_name = name
    end

    # Declares an accesser to a certain xml element, whether an attribute, a node,
    # or a typed collection of nodes
    #
    # [sym]   Symbol representing the name of the accessor
    #
    # == Type options
    # [:attr] Declare an accessor that represents an XML attribute.
    #         May be used as the type argument to indicate just type,
    #         or used as :from to indicate both type and attribute name
    #
    # Example:
    #  class Book
    #   xml_reader :isbn, :attr => "ISBN"
    #   xml_accessor :title, :attr
    #  end
    #
    # To map:
    #  <book ISBN="0974514055" title="Programming Ruby: the pragmatic programmers' guide" />
    #
    # [:text] The default type, if none is specified. Declares an accessor that
    #         represents a text node from XML.  May be left out completely, used
    #         as the type argument, or used as :from to indicate both the type and attribute name.
    #
    # Example:
    #  class Book
    #    xml :author, false, :text => 'Author'
    #    xml_accessor :description, :text, :as => :cdata
    #    xml_reader :title
    #  end
    #
    # To map:
    #  <book>
    #   <title>Programming Ruby: the pragmatic programmers' guide</title>
    #   <description><![CDATA[Probably the best Ruby book out there]]></description>
    #   <Author>David Thomas</author>
    #  </book>
    #
    # [:text_content] A special case of :text, this refers to the content of the current node,
    #                 rather than a sub-node
    #
    # Example:
    #  class Contributor
    #    xml_reader :name, :text_content
    #    xml_reader :role, :attr
    #  end
    #
    # To map:
    #  <contributor role="editor">James Wick</contributor>
    #
    # [type] Declares an accessor that represents another ROXML class as child XML element
    # (one-to-one or composition) or array of child elements (one-to-many or
    # aggregation) of this type. Default is one-to-one. Use :array option for one-to-many, or
    # simply pass the class in an array.
    #
    # Composition example:
    #  <book>
    #   <publisher>
    #     <name>Pragmatic Bookshelf</name>
    #   </publisher>
    #  </book>
    #
    # Can be mapped using the following code:
    #   class Book
    #     xml_reader :publisher, Publisher
    #   end
    #
    # Aggregation example:
    #  <library>
    #   <books>
    #    <book/>
    #    <book/>
    #   </books>
    #  </library>
    #
    # Can be mapped using the following code:
    #  class Library
    #    xml_reader :books, [Book], :in => "books"
    #  end
    #
    # If you don't have the <books> tag to wrap around the list of <book> tags:
    #  <library>
    #   <name>Ruby books</name>
    #   <book/>
    #   <book/>
    #  </library>
    #
    # You can skip the wrapper argument:
    #    xml_object :books, Book, :as => :array
    #
    # == Common options
    # [:from]  The name by which the xml value will be found, either an
    #      attribute or tag name in XML.  Default is sym, or the singular form
    #      of sym, in the case of arrays and hashes.
    # [:as] :cdata for character data, :array for one-to-many (or both)
    # [:in] An optional name of a wrapping tag for this XML accessor.
    # [:else] Default value for attribute, if missing
    #
    def xml(sym, writable = false, *args, &block)
      opts = Opts.new(sym, *args)

      tag_refs << case opts.type
      when :attr
        XMLAttributeRef.new(sym, opts, &block)
      when :text_content
        XMLTextRef.new(sym, opts, &block)
      when :text
        XMLTextRef.new(sym, opts, &block)
      when :hash
        XMLHashRef.new(sym, opts, &block)
      when Symbol
        raise ArgumentError, "Invalid type argument #{opts.type}"
      else # object
        XMLObjectRef.new(sym, opts, &block)
      end
      add_accessor(sym, writable, opts.array?, opts.default)
    end

    # Declares a read-only xml reference. See xml for details.
    def xml_reader(sym, *args, &block)
      xml sym, false, *args, &block
    end

    # Declares a writable xml reference. See xml for details.
    def xml_accessor(sym, *args, &block)
      xml sym, true, *args, &block
    end

    def xml_construction_args # ::nodoc::
      @xml_construction_args ||= []
    end

    # On parse, call the target object's initialize function with the listed arguments
    def xml_construct(*args)
      if missing_tag = args.detect {|arg| !tag_refs.map(&:name).include?(arg.to_s) }
        raise ArgumentError, "All construction tags must be declared as xml_object, " +
                             "xml_text, or xml_attribute. #{missing_tag} is missing. " +
                             tag_refs.map(&:name).join(', ') + ' are declared.'
      end
      @xml_construction_args = args
    end

    # Returns the tag name (also known as xml_name) of the class.
    # If no tag name is set with xml_name method, returns default class name
    # in lowercase.
    def tag_name
      @tag_name ||= self.name.split('::').last.downcase
    end

    # Returns array of internal reference objects, such as attributes
    # and composed XML objects
    def tag_refs
      @xml_refs ||= []
    end

  private
    def assert_accessor(name)
      @tag_accessors ||= []
      raise "Accessor #{name} is already defined as XML accessor in class #{self}" if @tag_accessors.include?(name)
      @tag_accessors << name
    end

    def add_accessor(name, writable, as_array, default = nil)
      assert_accessor(name)
      unless instance_methods.include?(name)
        default ||= Array.new if as_array

        define_method(name) do
          val = instance_variable_get("@#{name}")
          if val.nil?
            val = default
            instance_variable_set("@#{name}", val)
          end
          val
        end
      end
      if writable && !instance_methods.include?("#{name}=")
        define_method("#{name}=") do |v|
          instance_variable_set("@#{name}", v)
        end
      end
    end
  end

  class << self
    #
    # Extends the klass with the ROXML_Class module methods.
    #
    def included(klass)
      super
      klass.__send__(:extend, ROXML_Class)
    end
  end

  #
  # To make it easier to reference the class's
  # attributes all method calls to the instance that
  # doesn't match an instance method are forwarded to the
  # class's singleton instance. Only methods starting with 'tag_' are delegated.
  def method_missing(name, *args)
    if name.id2name =~ /^tag_/
      self.class.__send__(name, *args)
    else
      super
    end
  end
end

