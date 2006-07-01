# ROXML Ruby Object to XML mapping library. For more information
# visit http://roxml.rubyforge.org
#
# Copyright (c) 2004-2006 Zak Mandhro and Anders Engstrom
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# 
# =Quick Start Guide
#
# This is a short usage example. See ROXML::ROXML_Class and packaged test cases for more information.
#
# Consider an XML document representing a Library containing a number of Books. You
# can map this structure to Ruby classes that provide addition useful behavior. With
# ROXML, you can annotate the Ruby classes as follows:
#
#   class Book
#       include ROXML
#
#       xml_attribute :isbn, "ISBN"
#       xml_text :title
#       xml_text :description, nil, ROXML::TAG_CDATA
#       xml_text :author
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
#   book = Book.new()
#   book.isbn = "0201710897"
#   book.title = "The PickAxe"
#   book.description = "Best Ruby book out there!"
#   book.author = "David Thomas, Andrew Hunt, Dave Thomas"
#
#   lib = Library.new()
#   lib.name = "Favorite Books"
#   lib << book
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
# Similarly, to do a one-to-one mapping between XML objects, such as book and publisher,
# you would use the *xml_object* annotation. For example:
# 
# 	<book isbn="0974514055">
# 	  <title>Programming Ruby - 2nd Edition</title>
# 	  <description>Second edition of the great book.</description>
# 	  <publisher>
# 	  	<name>Pragmatic Bookshelf</name>
# 	  </publisher>
# 	</book>
# 
# can be mapped using the following code:
# 
# 	class BookWithPublisher
#   	include ROXML
# 
# 	    xml_name :book
# 	    xml_object :publisher, Publisher
# 	end
# 
# Note: In the above example, _xml_name_ annotation tells ROXML to set the element
# name to "book" for mapping to XML. The default is XML element name is the class name in lowercase; "bookwithpublisher"
# in this case.
# 
# For more information on available annotations, see ROXML::ROXML_Class
module ROXML

    require 'rexml/document'

    # Option that may be used to declare that 
    # a variable accessor should be read-only (no "accessor=(val)" is generated).
    TAG_READONLY = 1

    # Option that declares that an XML text element should be
    # wrapped in a CDATA section.
    TAG_CDATA = 2

    # Option that declares an accessor as an array (referencing "many"
    # items).
    TAG_ARRAY = 4

    #
    # Internal base class that represents an XML - Class binding.
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
        # passed in element (XML) with data.
        #
        # <b>Returns</b>: The updated XML node.
        def update_xml(xml, value)
            xml
        end

        # Reads data from the XML element and populates the object
        # instance accordingly.
        #
        # <b>Returns</b>: The updated instance.
        def populate(xml, instance)
            instance
        end
    end

    # Interal class representing an XML attribute binding
    # 
    # In context:
    #   <element attribute="XMLAttributeRef">
    #     XMLTextRef
    #   </element>
    class XMLAttributeRef < XMLRef
        # Updates the attribute in the given XML block to
        # the value provided.
        def update_xml(xml, value)
            xml.attributes[name] = value.to_s.to_utf
            xml
        end

        # Reads data from the XML element and populates the object
        # instance accordingly.
        def populate(xml, instance)
            instance.instance_variable_set("@#{accessor}", xml.attributes[name])
            instance
        end
    end

    # Interal class representing XML content text binding
    # 
    # In context:
    #   <element attribute="XMLAttributeRef">
    #     XMLTextRef
    #   </element>
    class XMLTextRef < XMLAttributeRef
        attr_accessor :cdata, :wrapper

        # Updates the text in the given _xml_ block to
        # the _value_ provided.
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

        # Reads data from the XML element and populates the text
        # accordingly.
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

        # Updates the composed XML object in the given XML block to
        # the value provided.
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

        # Reads data from the XML element and populates the references XML
        # object accordingly.
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
        # The input data is either a REXML::Element or a String representing
        # the XML document.
        #
        # Example
        #   book = Book.parse(File.read("book.xml"))
        # or
        #   book = Book.parse("<book><name>Beyond Java</name></book>")
        #
        def parse(data)

            xml = (data.kind_of?(REXML::Element) ? data : REXML::Document.new(data).root)
            
            inst = self.allocate

            tag_refs.each do |ref|
                ref.populate(xml, inst)                
            end
        
            return inst
        end
    
        # Sets the name of the XML element that represents this class. Use this
        # to override the default lowercase class name.
        # 
        # Example:
        #   class BookWithPublisher
        #     xml_name :book
        #   end
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
        # [sym]     Symbol representing the name of the accessor
        # [name]    An optional name that should be used for the attribute in XML.
        #           Default is sym.id2name.
        # [options] Valid options are TAG_READONLY to attribute as read-only
        # 
        # Example:
        #   class Book
        #     xml_attribute :isbn, "ISBN"
        #   end
        # 
        # To map:
        #   <book ISBN="0974514055"></book>
        #   
        def xml_attribute(sym, name = nil, options = 0)
            add_ref(XMLAttributeRef.new(sym, name))
            add_accessor(sym, (TAG_READONLY & options != TAG_READONLY))
        end

        #
        # Declares an accessor that represents one or more XML text elements.
        #
        # [sym]     Symbol representing the name of the accessor.
        # [name]    An optional name that should be used for the attribute in XML.
        #           Default is sym.id2name.
        # [options] TAG_CDATA for character data, TAG_ARRAY for one-to-many, and
        #           TAG_READONLY for read-only access.
        # [wrapper] An optional name of a wrapping tag for this XML accessor.
        #
        # Example:
        #   class Book
        #     xml_text :description, nil, ROXML::TAG_CDATA
        #   end
        # 
        # To map:
        #   <book>
        #     <description><![CDATA[Probably the best Ruby book out there]]></description>
        #   </book>
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
        # Declares an accessor that represents another ROXML class as child XML element
        # (one-to-one or composition) or array of child elements (one-to-many or
        # aggregation). Default is one-to-one. Use TAG_ARRAY option for one-to-many.
        #
        # [sym]     Symbol representing the name of the accessor.
        # [name]    An optional name that should be used for the attribute in XML.
        #           Default is sym.id2name.
        # [options] TAG_ARRAY for one-to-many, and TAG_READONLY for read-only access.
        # [wrapper] An optional name of a wrapping tag for this XML accessor.
        # 
        # Composition example:
        # 	<book>
        # 	  <publisher>
        # 	  	<name>Pragmatic Bookshelf</name>
        # 	  </publisher>
        # 	</book>
        # 
        # Can be mapped using the following code:
        # 	class Book
        # 	    xml_object :publisher, Publisher
        # 	end
        # 
        # Aggregation example:
        #   <library>
        #     <name>Ruby books</name>
        #     <books>
        #       <book/>
        #       <book/>
        #     </books>
        #   </library>
        #
        # Can be mapped using the following code:
        #   class Library
        #       xml_text :name, nil, ROXML::TAG_CDATA
        #       xml_object :books, Book, ROXML::TAG_ARRAY, "books"
        #   end
        # 
        # If you don't have the <books> tag to wrap around the list of <book> tags:
        #   <library>
        #     <name>Ruby books</name>
        #     <book/>
        #     <book/>
        #   </library>
        # 
        # You can skip the wrapper argument:
        #       xml_object :books, Book, ROXML::TAG_ARRAY
        #       
        def xml_object(sym, klass, options = 0, wrapper = nil)
            ref = XMLObjectRef.new(sym, nil) do |r|
                r.array = (TAG_ARRAY & options == TAG_ARRAY)
                r.wrapper = wrapper if wrapper
                r.klass = klass
            end
            add_ref(ref)
            add_accessor(sym, (TAG_READONLY & options != TAG_READONLY), ref.array)
        end

        # Returns the tag name (also known as xml_name) of the class.
        # If no tag name is set with xml_name method, returns default class name
        # in lowercase.
        def tag_name
            @tag_name || self.name.downcase
        end

        # Returns array of internal reference objects, such as attributes
        # and composed XML objects
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
            raise "Accessor #{name} is already defined as XML accessor in class #{self}" if @tag_accessors.include?(name)
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

