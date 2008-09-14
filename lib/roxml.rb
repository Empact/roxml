require 'rubygems'
require 'extensions/enumerable'
require 'extensions/array'
require 'activesupport'

%w(array string options xml).each do |file|
  require File.join(File.dirname(__FILE__), 'roxml', file)
end

module ROXML
  # This class defines the annotation methods that are mixed into your
  # Ruby classes for XML mapping information and behavior.
  #
  # See xml_name, xml_construct, xml, xml_reader and xml_accessor for
  # available annotations.
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
    # All type arguments may be used as the type argument to indicate just type,
    # or used as :from, pointing to a xml name to indicate both type and attribute name.
    # Also, any type may be passed via an array to indicate that multiple instances
    # of the object should be returned as an array.
    #
    # === :attr
    # Declare an accessor that represents an XML attribute.
    #
    # Example:
    #  class Book
    #   xml_reader :isbn, :attr => "ISBN" # 'ISBN' is used to specify :from
    #   xml_accessor :title, :attr        # :from defaults to :title
    #  end
    #
    # To map:
    #  <book ISBN="0974514055" title="Programming Ruby: the pragmatic programmers' guide" />
    #
    # === :text
    # The default type, if none is specified. Declares an accessor that
    # represents a text node from XML.
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
    # === :text_content
    # A special case of :text, this refers to the content of the current node,
    # rather than a sub-node
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
    # === Hash
    # Somewhere between the simplicity of a :text/:attr mapping, and the complexity of
    # a full Object/Type mapping, lies the Hash mapping.  It serves in the case where you have
    # a collection of key-value pairs represented in your xml.  You create a hash declaration by
    # passing a hash mapping as the type argument.  A few examples:
    #
    # ==== Hash of :attrs
    # For xml such as this:
    #
    #    <dictionary>
    #      <definitions>
    #        <definition dt="quaquaversally"
    #                    dd="adjective: (of a geological formation) sloping downward from the center in all directions." />
    #        <definition dt="tergiversate"
    #                    dd="To use evasions or ambiguities; equivocate." />
    #      </definitions>
    #    </dictionary>
    #
    # You can use the :attrs key in you has with a [:key, :value] name array:
    #
    #    xml_reader :definitions, {:attrs => [:dt, :dd]}, :in => :definitions
    #
    # ==== Hash of :texts
    # For xml such as this:
    #
    #    <dictionary>
    #      <definition>
    #        <word/>
    #        <meaning/>
    #      </definition>
    #      <definition>
    #        <word/>
    #        <meaning/>
    #      </definition>
    #    </dictionary>
    #
    # You can individually declare your key and value names:
    #    xml_reader :definitions, {:key => :word,
    #                              :value => :meaning}
    #
    # ==== Hash of :text_content &c.
    # For xml such as this:
    #
    #    <dictionary>
    #      <definition word="quaquaversally">adjective: (of a geological formation) sloping downward from the center in all directions.</definition>
    #      <definition word="tergiversate">To use evasions or ambiguities; equivocate.</definition>
    #    </dictionary>
    #
    # You can individually declare the key and value, but with the attr, you need to provide both the type
    # and name of that type (i.e. {:attr => :word}), because omitting the type will result in ROXML
    # defaulting to :text
    #    xml_reader :definitions, {:key => {:attr => :word},
    #                              :value => :text_content}
    #
    # === Other ROXML Class
    # Declares an accessor that represents another ROXML class as child XML element
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
    # == Blocks
    # For any attribute, you may pass a block which manipulates the associated parsed value.
    #
    #  class Muffins
    #    include ROXML
    #
    #    xml_reader :count, :from => 'bakers_dozens' {|val| val.to_i * 13 }
    #  end
    #
    # For hash types, the block recieves the key and value as arguments, and they should
    # be returned as an array of [key, value]
    #
    # == Other options
    # [:from] The name by which the xml value will be found, either an attribute or tag name in XML.  Default is sym, or the singular form of sym, in the case of arrays and hashes.
    # [:as] :cdata for character data, and/or :array for one-to-many
    # [:in] An optional name of a wrapping tag for this XML accessor
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
        raise ArgumentError, "All construction tags must be declared first using xml, " +
                             "xml_reader, or xml_accessor. #{missing_tag} is missing. " +
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
    def included(klass) # ::nodoc::
      super
      klass.__send__(:extend, ROXML_Class)
    end
  end

  #
  # To make it easier to reference the class's
  # attributes all method calls to the instance that
  # doesn't match an instance method are forwarded to the
  # class's singleton instance. Only methods 'tag_name' and 'tag_refs' are delegated.
  def method_missing(name, *args)
    if [:tag_name, :tag_refs].include? name
      self.class.__send__(name, *args)
    else
      super
    end
  end
end

