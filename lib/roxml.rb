require 'uri'

require 'active_support'
require 'active_support/inflector/inflections'
require 'active_support/core_ext/object/duplicable'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/string/starts_ends_with'

require 'roxml/definition'
require 'roxml/xml'

module ROXML # :nodoc:
  VERSION = '3.1.5'

  def self.included(base) # :nodoc:
    base.class_eval do
      extend  ClassMethods::Accessors,
              ClassMethods::Declarations,
              ClassMethods::Operations
      include InstanceMethods

      attr_accessor :roxml_references
    end
  end

  module InstanceMethods # :nodoc:
    # Returns an XML object representing this object
    def to_xml(params = {})
      params.reverse_merge!(:name => self.class.tag_name, :namespace => self.class.roxml_namespace)
      params[:namespace] = nil if ['*', 'xmlns'].include?(params[:namespace])
      XML.new_node([params[:namespace], params[:name]].compact.join(':')).tap do |root|
        refs = (self.roxml_references.present? \
          ? self.roxml_references \
          : self.class.roxml_attrs.map {|attr| attr.to_ref(self) })
        refs.each do |ref|
          value = ref.to_xml(self)
          unless value.nil?
            ref.update_xml(root, value)
          end
        end
      end
    end
  end

  # This class defines the annotation methods that are mixed into your
  # Ruby classes for XML mapping information and behavior.
  #
  # See xml_name, xml_initialize, xml, xml_reader and xml_accessor for
  # available annotations.
  #
  module ClassMethods # :nodoc:
    module Declarations
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
        @roxml_tag_name = name
      end

      # Sets the namemespace for attributes and elements of this class.  You can override
      # this value on individual elements via the :from option
      #
      # Example:
      #  class Book
      #   xml_namespace :aws
      #
      #   xml_reader :default_namespace
      #   xml_reader :different_namespace, :from => 'different:namespace'
      #   xml_reader :no_namespace, :from => 'no_namespace', :namespace => false
      #  end
      #
      # <aws:book xmlns:aws="http://www.aws.com/aws" xmlns:different="http://www.aws.com/different">
      #   <aws:default_namespace>value</aws:default_namespace>
      #   <different:namespace>value</different:namespace>
      #   <no_namespace>value</no_namespace>
      # </aws:book>
      #
      def xml_namespace(namespace)
        @roxml_namespace = namespace.to_s
      end
      
      # Sets up a mapping of namespace prefixes to hrefs, to be used by this class.
      # These namespace prefixes are independent of what appears in the xml, only
      # the namespace hrefs themselves need to match
      #
      # Example:
      #  class Tires
      #    include ROXML
      #
      #    xml_namespaces \
      #      :bobsbike => 'http://bobsbikes.example.com',
      #      :alicesauto => 'http://alicesautosupply.example.com/'
      #
      #    xml_reader :bike_tires, :as => [], :from => '@name', :in => 'bobsbike:tire'
      #    xml_reader :car_tires, :as => [], :from => '@name', :in => 'alicesauto:tire'
      #  end
      #
      #  >> xml = %{
      #    <?xml version="1.0"?>
      #    <inventory xmlns="http://alicesautosupply.example.com/" xmlns:bike="http://bobsbikes.example.com">
      #     <tire name="super slick racing tire" />
      #     <tire name="all weather tire" />
      #     <bike:tire name="skinny street" />
      #    </inventory>
      #  }
      #  >> Tires.from_xml(xml).bike_tires
      #  => ['skinny street']
      #
      def xml_namespaces(namespaces)
        @roxml_namespaces = namespaces.inject({}) do |all, (prefix, href)|
          all[prefix.to_s] = href.to_s
          all
        end
      end

      def roxml_namespaces # :nodoc:
        @roxml_namespaces || {}
      end

      # Most xml documents have a consistent naming convention, for example, the node and
      # and attribute names might appear in CamelCase. xml_convention enables you to adapt
      # the roxml default names for this object to suit this convention.  For example,
      # if I had a document like so:
      #
      #  <XmlDoc>
      #    <MyPreciousData />
      #    <MoreToSee InAttrs="" />
      #  </XmlDoc>
      #
      # Then I could access it's contents by defining the following class:
      #
      #  class XmlDoc
      #    include ROXML
      #    xml_convention :camelcase
      #    xml_reader :my_precious_data
      #    xml_reader :in_attrs, :in => 'MoreToSee'
      #  end
      #
      # You may supply a block or any #to_proc-able object as the argument,
      # and it will be called against the default node and attribute names before searching
      # the document.  Here are some example declaration:
      #
      #  xml_convention :upcase
      #  xml_convention &:camelcase
      #  xml_convention {|val| val.gsub('_', '').downcase }
      #
      # See ActiveSupport::CoreExtensions::String::Inflections for more prepackaged formats
      #
      # Note that the xml_convention is also applied to the default root-level tag_name,
      # but in this case an underscored version of the name is applied, for convenience.
      def xml_convention(to_proc_able = nil, &block)
        raise ArgumentError, "conventions are already set" if @roxml_naming_convention
        @roxml_naming_convention =
          if to_proc_able
            raise ArgumentError, "only one conventions can be set" if block_given?
            to_proc_able.to_proc
          elsif block_given?
            block
          end
      end

      def roxml_naming_convention # :nodoc:
        (@roxml_naming_convention || begin
          superclass.roxml_naming_convention if superclass.respond_to?(:roxml_naming_convention)
        end).freeze
      end

      # Declares a reference to a certain xml element, whether an attribute, a node,
      # or a typed collection of nodes.  This method does not add a corresponding accessor
      # to the object.  For that behavior see the similar methods: .xml_reader and .xml_accessor.
      #
      # == Sym Option
      # [sym]   Symbol representing the name of the accessor.
      #
      # === Default naming
      # This name will be the default node or attribute name searched for,
      # if no other is declared.  For example,
      #
      #  xml_reader   :bob
      #  xml_accessor :pony, :from => :attr
      #
      # are equivalent to:
      #
      #  xml_reader   :bob, :from => 'bob'
      #  xml_accessor :pony, :from => '@pony'
      #
      # === Boolean attributes
      # If the name ends in a ?, ROXML will attempt to coerce the value to true or false,
      # with True, TRUE, true and 1 mapping to true and False, FALSE, false and 0 mapping
      # to false, as shown below:
      #
      #  xml_reader :desirable?
      #  xml_reader :bizzare?, :from => '@BIZZARE'
      #
      #  x = #from_xml(%{
      #    <object BIZZARE="1">
      #      <desirable>False</desirable>
      #    </object>
      #  })
      #  x.desirable?
      #  => false
      #  x.bizzare?
      #  => true
      #
      # If an unexpected value is encountered, the attribute will be set to nil,
      # unless you provide a block, in which case the block will recived
      # the actual unexpected value.
      #
      #  #from_xml(%{
      #    <object>
      #      <desirable>Dunno</desirable>
      #    </object>
      #  }).desirable?
      #  => nil
      #
      #  xml_reader :strange? do |val|
      #    val.upcase
      #  end
      #
      #  #from_xml(%{
      #    <object>
      #      <strange>Dunno</strange>
      #    </object>
      #  }).strange?
      #  => DUNNO
      #
      # == Blocks
      # You may also pass a block which manipulates the associated parsed value.
      #
      #  class Muffins
      #    include ROXML
      #
      #    xml_reader(:count, :from => 'bakers_dozens') {|val| val.to_i * 13 }
      #  end
      #
      # For hash types, the block recieves the key and value as arguments, and they should
      # be returned as an array of [key, value]
      #
      # For array types, the entire array is passed in, and must be returned in the same fashion.
      #
      # == Options
      # === :as
      # ==== Basic Types
      # Allows you to specify one of several basic types to return the value as.  For example
      #
      #  xml_reader :count, :as => Integer
      #
      # is equivalent to:
      #
      #  xml_reader(:count) {|val| Integer(val) unless val.empty? }
      #
      # Such block shorthands for Integer, Float, Fixnum, BigDecimal, Date, Time, and DateTime
      # are currently available, but only for non-Hash declarations.
      #
      # To reference many elements, put the desired type in a literal array. e.g.:
      #
      #   xml_reader :counts, :as => [Integer]
      #
      # Even an array of text nodes can be specified with :as => []
      #
      #   xml_reader :quotes, :as => []
      #
      # === Other ROXML Class
      # Declares an accessor that represents another ROXML class as child XML element
      # (one-to-one or composition) or array of child elements (one-to-many or
      # aggregation) of this type. Default is one-to-one. For one-to-many, simply pass the class
      # as the only element in an array.
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
      #     xml_reader :publisher, :as => Publisher
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
      #    xml_reader :books, :as => [Book], :in => "books"
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
      #    xml_reader :books, :as => [Book]
      #
      # ==== Hash
      # Somewhere between the simplicity of a :text/:attr mapping, and the complexity of
      # a full Object/Type mapping, lies the Hash mapping.  It serves in the case where you have
      # a collection of key-value pairs represented in your xml.  You create a hash declaration by
      # passing a hash mapping as the type argument.  A few examples:
      #
      # ===== Hash of element contents
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
      #    xml_reader :definitions, :as => {:key => 'word',
      #                                     :value => 'meaning'}
      #
      # ===== Hash of :content &c.
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
      #    xml_reader :definitions, :as => {:key => {:attr => 'word'},
      #                                     :value => :content}
      #
      # ===== Hash of :name &c.
      # For xml such as this:
      #
      #    <dictionary>
      #      <quaquaversally>adjective: (of a geological formation) sloping downward from the center in all directions.</quaquaversally>
      #      <tergiversate>To use evasions or ambiguities; equivocate.</tergiversate>
      #    </dictionary>
      #
      # You can pick up the node names (e.g. quaquaversally) using the :name keyword:
      #    xml_reader :definitions, :as => {:key => :name,
      #                                     :value => :content}
      #
      # === :from
      # The name by which the xml value will be found, either an attribute or tag name in XML.
      # Default is sym, or the singular form of sym, in the case of arrays and hashes.
      #
      # This value may also include XPath notation.
      #
      # ==== :from => :content
      # When :from is set to :content, this refers to the content of the current node,
      # rather than a sub-node. It is equivalent to :from => '.'
      #
      # Example:
      #  class Contributor
      #    xml_reader :name, :from => :content
      #    xml_reader :role, :from => :attr
      #  end
      #
      # To map:
      #  <contributor role="editor">James Wick</contributor>
      #
      # ==== :from => :attr
      # When :from is set to :attr, this refers to the content of an attribute,
      # rather than a sub-node. It is equivalent to :from => '@attribute_name'
      #
      # Example:
      #  class Book
      #    xml_reader :isbn, :from => "@ISBN"
      #    xml_accessor :title, :from => :attr # :from defaults to '@title'
      #  end
      #
      # To map:
      #  <book ISBN="0974514055" title="Programming Ruby: the pragmatic programmers' guide" />
      #
      # ==== :from => :text
      # The default source, if none is specified, this means the accessor
      # represents a text node from XML.  This is documented for completeness
      # only.  You should just leave this option off when you want the default behavior,
      # as in the examples below.
      #
      # :text is equivalent to :from => accessor_name, and you should specify the
      # actual node name (and, optionally, a namespace) if it differs, as in the case of :author below.
      #
      # Example:
      #  class Book
      #    xml_reader :author, :from => 'Author'
      #    xml_accessor :description, :cdata => true
      #    xml_reader :title
      #  end
      #
      # To map:
      #  <book>
      #   <title>Programming Ruby: the pragmatic programmers' guide</title>
      #   <description><![CDATA[Probably the best Ruby book out there]]></description>
      #   <Author>David Thomas</Author>
      #  </book>
      #
      # Likewise, a number of :text node values can be collected in an array like so:
      #
      # Example:
      #  class Library
      #    xml_reader :books, :as => []
      #  end
      #
      # To map:
      #  <library>
      #      <book>To kill a mockingbird</book>
      #      <book>House of Leaves</book>
      #    <book>Gödel, Escher, Bach</book>
      #  </library>
      #
      # === Other Options
      # [:in] An optional name of a wrapping tag for this XML accessor.
      #       This can include other xpath values, which will be joined with :from with a '/'
      # [:else] Default value for attribute, if missing from the xml on .from_xml
      # [:required] If true, throws RequiredElementMissing when the element isn't present
      # [:frozen] If true, all results are frozen (using #freeze) at parse-time.
      # [:cdata] true for values which should be input from or output as cdata elements
      # [:to_xml] this proc is applied to the attributes value outputting the instance via #to_xml
      # [:namespace] (false) disables or (string) overrides the default namespace declared with xml_namespace
      #
      def xml_attr(*syms, &block)
        opts = syms.extract_options!
        syms.map do |sym|
          Definition.new(sym, opts, &block).tap do |attr|
            if roxml_attrs.map(&:accessor).include? attr.accessor
              raise "Accessor #{attr.accessor} is already defined as XML accessor in class #{self.name}"
            end
            @roxml_attrs << attr
          end
        end
      end

      # Declares a read-only xml reference. See xml_attr for details.
      #
      # Note that while xml_reader does not create a setter for this attribute,
      # its value can be modified indirectly via methods.  For more complete
      # protection, consider the :frozen option.
      def xml_reader(*syms, &block)
        xml_attr(*syms, &block).each do |attr|
          add_reader(attr)
        end
      end

      # Declares a writable xml reference. See xml_attr for details.
      #
      # Note that while xml_accessor does create a setter for this attribute,
      # you can use the :frozen option to prevent its value from being
      # modified indirectly via methods.
      def xml_accessor(*syms, &block)
        xml_attr(*syms, &block).each do |attr|
          add_reader(attr)
          attr_writer(attr.attr_name)
        end
      end

    private
      def add_reader(attr)
        define_method(attr.accessor) do
          instance_variable_get(attr.instance_variable_name)
        end
      end
    end

    module Accessors
      # Returns the tag name (also known as xml_name) of the class.
      # If no tag name is set with xml_name method, returns default class name
      # in lowercase.
      #
      # If xml_convention is set, it is called with an *underscored* version of
      # the class name.  This is because active support's inflector generally expects
      # an underscored version, and several operations (e.g. camelcase(:lower), dasherize)
      # do not work without one.
      def tag_name
        return roxml_tag_name if roxml_tag_name
        
        if tag_name = name.split('::').last
          roxml_naming_convention ? roxml_naming_convention.call(tag_name.underscore) : tag_name.downcase
        end
      end

      def roxml_tag_name # :nodoc:
        @roxml_tag_name || begin
          superclass.roxml_tag_name if superclass.respond_to?(:roxml_tag_name)
        end
      end

      def roxml_namespace # :nodoc:
        @roxml_namespace || begin
          superclass.roxml_namespace if superclass.respond_to?(:roxml_namespace)
        end
      end

      # Returns array of internal reference objects, such as attributes
      # and composed XML objects
      def roxml_attrs
        @roxml_attrs ||= []
        (@roxml_attrs + (superclass.respond_to?(:roxml_attrs) ? superclass.roxml_attrs : [])).freeze
      end
    end

    module Operations
      #
      # Creates a new Ruby object from XML using mapping information
      # annotated in the class.
      #
      # The input data is either an XML::Node, String, Pathname, or File representing
      # the XML document.
      #
      # Example
      #  book = Book.from_xml(File.read("book.xml"))
      # or
      #  book = Book.from_xml("<book><name>Beyond Java</name></book>")
      #
      # _initialization_args_ passed into from_xml will be passed into
      # the object's .new, prior to populating the xml_attrs.
      #
      # After the instatiation and xml population
      #
      # See also: xml_initialize
      #
      def from_xml(data, *initialization_args)
        xml = XML::Node.from(data)

        new(*initialization_args).tap do |inst|
          inst.roxml_references = roxml_attrs.map {|attr| attr.to_ref(inst) }

          inst.roxml_references.each do |ref|
            value = ref.value_in(xml)
            inst.respond_to?(ref.opts.setter) \
              ? inst.send(ref.opts.setter, value) \
              : inst.instance_variable_set(ref.opts.instance_variable_name, value)
          end
          inst.send(:after_parse) if inst.respond_to?(:after_parse, true)
        end
      rescue ArgumentError => e
        raise e, e.message + " for class #{self}"
      end
    end
  end
end

