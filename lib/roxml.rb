require 'rubygems'
require 'activesupport'

%w(string xml).each do |file|
  require File.join(File.dirname(__FILE__), 'roxml', file)
end

module ROXML
  # Default tag behavior declaration with single
  # read and write.
  TAG_DEFAULT = nil

  # Option that may be used to declare that
  # a variable accessor should be read-only (no "accessor=(val)" is generated).
  TAG_READONLY = :readonly

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

    #
    # Declare an accessor for the included class that should be
    # represented as an XML attribute.
    #
    # [sym]   Symbol representing the name of the accessor
    # [:from]  An optional name that should be used for the attribute in XML.
    #      Default is sym.id2name.
    # [:as] Valid options are :readonly to attribute as read-only
    #
    # Example:
    #  class Book
    #   xml_attribute :isbn, :from => "ISBN"
    #  end
    #
    # To map:
    #  <book ISBN="0974514055"></book>
    #
    def xml_attribute(sym, args = {})
      args.reverse_merge! :from => nil, :as => nil
      tag_refs << XMLAttributeRef.new(sym, args[:from])
      add_accessor(sym, args[:as] != :readonly)
    end

    #
    # Declares an accessor that represents one or more XML text elements.
    #
    # [sym]   Symbol representing the name of the accessor.
    # [:from]  An optional name that should be used for the attribute in XML.
    #      Default is sym.id2name.
    # [:as] :cdata for character data, :array for one-to-many,
    #      :text_content to declare main text content for containing tag,
    #      and :readonly for read-only access.
    # [:in] An optional name of a wrapping tag for this XML accessor.
    #
    # Example:
    #  class Author
    #   xml_attribute :role
    #   xml_text :text, :as => :text_content
    #  end
    #
    #  class Book
    #   xml_text :description, :as => :cdata
    #  end
    #
    # To map:
    #  <book>
    #   <description><![CDATA[Probably the best Ruby book out there]]></description>
    #   <author role="primary">David Thomas</author>
    #  </book>
    def xml_text(sym, args = {})
      args.reverse_merge! :from => nil, :in => nil, :as => []
      args[:as] = [*args[:as]]

      ref = XMLTextRef.new(sym, args[:from]) do |r|
        r.text_content = args[:as].include?(:text_content)
        r.cdata = args[:as].include?(:cdata)
        r.array = args[:as].include?(:array)
        r.wrapper = args[:in] if args[:in]
      end
      tag_refs << ref
      add_accessor(sym, !args[:as].include?(:readonly), ref.array)
    end

    #
    # Declares an accessor that represents another ROXML class as child XML element
    # (one-to-one or composition) or array of child elements (one-to-many or
    # aggregation). Default is one-to-one. Use :array option for one-to-many.
    #
    # [sym]   Symbol representing the name of the accessor.
    # [klass] The class of the object described
    # [:from]  An optional name that should be used for the attribute in XML.
    #      Default is sym.id2name.
    # [:as] :array for one-to-many, and :readonly for read-only access.
    # [:in] An optional name of a wrapping tag for this XML accessor.
    #
    # Composition example:
    # 	<book>
    # 	 <publisher>
    # 	 	<name>Pragmatic Bookshelf</name>
    # 	 </publisher>
    # 	</book>
    #
    # Can be mapped using the following code:
    # 	class Book
    # 	  xml_object :publisher, Publisher
    # 	end
    #
    # Aggregation example:
    #  <library>
    #   <name>Ruby books</name>
    #   <books>
    #    <book/>
    #    <book/>
    #   </books>
    #  </library>
    #
    # Can be mapped using the following code:
    #  class Library
    #    xml_text :name, :as => :cdata
    #    xml_object :books, Book, :as => [:readonly, :array], :in => "books"
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
    def xml_object(sym, klass, args = {})
      args.reverse_merge! :in => nil, :as => [], :from => nil
      args[:as] = [*args[:as]]

      ref = XMLObjectRef.new(sym, klass, args[:from]) do |r|
        r.array = args[:as].include?(:array)
        r.wrapper = args[:in] if args[:in]
      end
      tag_refs << ref
      add_accessor(sym, !args[:as].include?(:readonly), ref.array)
    end

    def xml_construction_args
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

    def add_accessor(name, writable = true, is_array = false)
      assert_accessor(name)
      unless instance_methods.include?(name)
        define_method(name) do
          returning instance_variable_get("@#{name}") do |val|
            if val.nil? && is_array
              val = Array.new
              instance_variable_set("@#{name}", val)
            end
          end
        end
      end
      if writable && !instance_methods.include?("#{name}=")
        define_method("#{name}=") do |v|
          instance_variable_set("@#{name}", v)
        end
      end
    end
  end ## End ROXML_Class module ##############

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

