#
# Mixin module that can be used to give ruby objects
# XML serialization support.
#
# $Id: roxml.rb,v 1.2 2004/07/22 19:59:03 andersengstrom Exp $
#
# =USAGE
#
# This is a short usage example. See the docs at roxml.rubyforge.org for further
# examples.
#
# Consider a <em>Library</em> containing a number of books. To describe that library and
# its books the following classes are defined:
#
#   class Book
#       include ROXML
#
#       xml_attribute :isdn, "ISDN"
#       xml_text :title
#       xml_text :description, nil, ROXML::TAG_CDATA
#       xml_text :author
#
#       def initialize
#           yield self if block_given?
#       end
#   end
#
#   class Library
#       include ROXML
#
#       xml_text :name, "NAME", ROXML::TAG_CDATA
#       xml_object :books, Book, ROXML::TAG_ARRAY, "books"
#   end
#
# To create a library and put a number of books in it we could run the following code:
#
#   lib = Library.new
#   lib.name = "My Funky Library"
#   
#   lib.books << Book.new do |book|
#       book.isdn = "0201710897"
#       book.title = "The PickAxe"
#       book.description = "Probably the best ruby book out there"
#       book.author = "David Thomas, Andrew Hunt, Dave Thomas"
#   end
#
#   lib.books << Book.new do |book|
#       book.isdn = "9248710987"
#       book.title = "The Wee Free Men"
#       book.author = "Terry Pratchett"
#       book.description = "Funny book about small, magic, swearing gnomes"
#   end
#
# To save this information to an XML file:
#
#   File.open("library.xml", "w") do |f|
#       lib.to_xml.write(f, 0)
#   end
#
# To later populate the library object from the XML file:
#
#   lib = Library.parse(File.read("library.xml"))
#
# =TODO
# * Introduce a "xml_hash" macro for specifying hash-like xml.
# * Consider better semantics for the macro methods.
# * Define life-cycle callbacks that can be implemented by the mixee class to
#   get notified of parsing/xml-generation.
module ROXML

    require 'rexml/document'

    # Option that may be used to declare that 
    # a variable accessor should be read-only (no "accessor=(val)" is generated).
    TAG_READONLY = 1

    # Option that declares that a xml text element should be
    # wrapped in a CDATA section.
    TAG_CDATA = 2

    # Option that declares an accessor as an array (referencing "many"
    # items).
    TAG_ARRAY = 4

    #
    # Internal base class that represents a XML - Class binding.
    # 
    class XMLRef 
        attr_accessor :accessor, :name, :array

        def initialize(accessor, name = nil)
            @accessor = accessor
            @name = (name || accessor.id2name)
            yield self if block_given?
            @array = false unless @array
        end
        
        # Converts this XML reference to XML and updates the
        # passed in element (xml) with data.
        #
        # <b>Returns</b>: The updated XML node.
        def update_xml(xml, value)
            xml
        end

        # Reads data from the xml element and populates the object
        # instance accordingly.
        #
        # <b>Returns</b>: The updated instance.
        def populate(xml, instance)
            instance
        end
    end

    class XMLAttributeRef < XMLRef
        def update_xml(xml, value)
            xml.attributes[name] = value.to_s.to_utf
            xml
        end

        def populate(xml, instance)
            instance.instance_variable_set("@#{accessor}", xml.attributes[name])
            instance
        end
    end

    class XMLTextRef < XMLAttributeRef
        attr_accessor :cdata, :wrapper

        def update_xml(xml, value)
            parent = (wrapper ? xml.add_element(wrapper) : xml)
            if array
                value.each do |v|
                    parent.add_element(name).text = (cdata ? REXML::CData.new(v.to_s.to_utf) : v.to_s.to_utf)   
                end
            else
                parent.add_element(name).text = (cdata ? REXML::CData.new(value.to_s.to_utf) : value.to_s.to_utf)
            end
            xml
        end

        def populate(xml, instance)
            data = nil
            unless array
                child = xml.elements[1, name]
                data = child.text if child && child.text
            else
                xpath = (wrapper ? "#{wrapper}/#{name}" : "#{name}")
                data = []
                xml.each_element(xpath) do |e|
                    if e.text
                        data << e.text.strip.to_latin                        
                    end
                end

            end
            instance.instance_variable_set("@#{accessor}", data) if data
            instance
        end
    end

    class XMLObjectRef < XMLTextRef
        attr_accessor :klass

        def update_xml(xml, value)
            parent = (wrapper ? xml.add_element(wrapper) : xml)
            unless array
                parent.add_element(value.to_xml)
            else
                value.each do |v|
                    parent.add_element(v.to_xml)
                end
            end
            xml
        end

        def populate(xml, instance)
            data = nil
            unless array
                child = xml.elements[1, klass.tag_name]
                if child
                    data = klass.parse(child)
                end
            else
                xpath = (wrapper ? "#{wrapper}/#{klass.tag_name}" : "#{klass.tag_name}")
                data = []
                xml.each_element(xpath) do |e|
                    data << klass.parse(e)
                end
            end
            instance.instance_variable_set("@#{accessor}", data) if data
            instance
        end
    end


    #
    # Internal module that is used to extend the target class
    # with macro-like functions for declaring xml settings.
    # This module should never be directly included or extended.
    #
    module ROXML_Class

    
        #
        # Creates a new object using an XML input tree.
        # 
        # The input data is either a REXML::Element or a String representing
        # the XML document.
        #
        def parse(data)

            xml = (data.kind_of?(REXML::Element) ? data : REXML::Document.new(data).root)
            
            inst = self.allocate

            tag_refs.each do |ref|
                ref.populate(xml, inst)                
            end
        
            return inst
        end
    
        #
        # States the name of the XML element that represents this class.
        # The default name of the XML element is otherwise the self.name.downcase.
        #
        def xml_name(name)
            @tag_name = name
        end

        #
        # Declare an accessor for the included class that should be 
        # represented as a XML attribute.
        #
        # [sym]     Symbol. The name of the accessor
        # [name]    String. An optional name that should be used for the attribute in XML.
        #           Default is sym.id2name.
        # [options] Valid options are TAG_READONLY. 
        # 
        def xml_attribute(sym, name = nil, options = 0)
            add_ref(XMLAttributeRef.new(sym, name))
            add_accessor(sym, (TAG_READONLY & options != TAG_READONLY))
        end

        #
        # Declares an accessor that represents one or more xml children.
        #
        # [sym]     Symbol. The name of the accessor.
        # [name]    String. See description in xml_attribute.
        # [options] Valid options are TAG_CDATA, TAG_ARRAY and TAG_READONLY.
        # [wrapper] An optional name of a wrapping tag for this xml accessor.
        def xml_text(sym, name = nil, options = 0, wrapper = nil)
            ref = XMLTextRef.new(sym, name) do |r|
                r.cdata = (TAG_CDATA & options == TAG_CDATA)
                r.array = (TAG_ARRAY & options == TAG_ARRAY)
                r.wrapper = wrapper if wrapper
            end
            add_ref(ref)
            add_accessor(sym, (TAG_READONLY & options != TAG_READONLY), ref.array)
        end
        
        #
        # Declares an accessor that represents another ROXML class.
        #
        # [sym]     Symbol. The name of the accessor.
        # [klass]   The referenced ROXML class.
        # [options] Valid options are TAG_ARRAY and TAG_READONLY.
        # [wrapper] See description in xml_text
        def xml_object(sym, klass, options = 0, wrapper = nil)
            ref = XMLObjectRef.new(sym, nil) do |r|
                r.array = (TAG_ARRAY & options == TAG_ARRAY)
                r.wrapper = wrapper if wrapper
                r.klass = klass
            end
            add_ref(ref)
            add_accessor(sym, (TAG_READONLY & options != TAG_READONLY), ref.array)
        end

        def tag_name
            @tag_name || self.name.downcase
        end

        def tag_refs
            @xml_refs || []
        end
    
        private

        def add_ref(xml_ref)
            @xml_refs = [] unless @xml_refs
            @xml_refs << xml_ref
        end

        def assert_accessor(name)
            @tag_accessors = [] unless @tag_accessors
            raise "Accessor #{name} is already defined as xml accessor in class #{self}" if @tag_accessors.include?(name)
            @tag_accessors << name
        end

        def add_accessor(name, writable = true, is_array = false)
            assert_accessor(name)
            unless instance_methods.include?(name)
                define_method(name) do
                    val = instance_variable_get("@#{name}")
                    if val.nil? && is_array
                        val = Array.new
                        instance_variable_set("@#{name}", val)
                    end
                    val
                end
            end
            if writable 
                unless instance_methods.include?("#{name}=")
                    define_method("#{name}=") do |v|
                        instance_variable_set("@#{name}", v)
                    end
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
    # Returns an REXML::Element representing this object.
    #
    def to_xml
        root = REXML::Element.new(tag_name)
        tag_refs.each do |ref|
            v = __send__(ref.accessor)
            if v
                root = ref.update_xml(root, v)
            end
        end
        root
    end

    #
    # To make it easier to reference the class's
    # attributes all method calls to the instance that
    # doesn't match an instance method are forwarded to the
    # class's singleton instance. Only methods starting with 'tag_' are delegated.
    #
    # TODO: There's not that many methods that need to be captured this way. Better
    # to bite the bullet and implement them properly in the instance mixin to boost
    # performance a bit.
    def method_missing(name, *args)
        if name.id2name =~ /^tag_/
            self.class.__send__(name, *args)
        else
            super
        end
    end

    # Extension of String class to handle conversion from/to
    # UTF-8/ISO-8869-1
    class ::String
        require 'iconv'
    
        #
        # Return an utf-8 representation of this string.
        #
        def to_utf
            begin
                Iconv.new("utf-8", "iso-8859-1").iconv(self)
            rescue Iconv::IllegalSequence => e
                STDERR << "!! Failed converting from UTF-8 -> ISO-8859-1 (#{self}). Already the right charset?"
                self
            end
        end

        #
        # Convert this string to iso-8850-1
        #
        def to_latin
            begin
                Iconv.new("iso-8859-1", "utf-8").iconv(self)
            rescue Iconv::IllegalSequence => e
                STDERR << "!! Failed converting from ISO-8859-1 -> UTF-8 (#{self}). Already the right charset?"
                self
            end
        end
    end

end

