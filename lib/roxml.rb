#
# Mixin module that can be used to give ruby objects
# XML serialization support.
#
# $Id: roxml.rb,v 1.1 2004/07/22 14:52:55 andersengstrom Exp $
#
# == Introduction
#    
# alksdfj lasdhf laiusdhf layugsd flyag sdg 
# asdf uiahsgiuha sldifuha lusyglasifasdf as a
# 
# === Purpose
# * skdfjhaksfdasd
# * sakfjshflkajhsf
# * asdkfjhasdjhfa
#
# == Usage
# sdlgh sldiufh sldiufh sldfugs d
# f gsödoifg ösuhdf shdf uhs dsd g
#
# === Creating a bound class
#
#   class Test
#       include ROXML
#
#       xml_name "test"
#       xml_attribute :id, "ID"
#       xml_text :title
#       xml_text :entries, "entry", ROXML::TAG_CDATA|ROXML::TAG_ARRAY, "entries"
#
#       def initialize
#           yield self if block_given?
#       end
#   end
#
#   Test.new do |t|
#       t.id = 10
#       t.title = "A Title"
#       t.entries << "entry_1"
#       t.entryies << "entry_2"
#   end.to_xml.write(STDOUT, 0)
#
# would yield:
#
#   <test ID="10">
#       <title>A Title</title>
#       <entries>
#           <entry><![CDATA[entry_1]]></entry>
#           <entry><![CDATA[entry_2]]></entry>
#       </entries>
#   </test>
#
#   
module ROXML

    require 'rexml/document'

    TAG_READONLY = 1
    TAG_CDATA = 2
    TAG_ARRAY = 4

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
        # === Returns
        # The updated XML node.
        def update_xml(xml, value)
            xml
        end

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
        #
        def xml_name(name)
            @tag_name = name
        end

        def xml_attribute(sym, name = nil, options = 0)
            add_ref(XMLAttributeRef.new(sym, name))
            add_accessor(sym, (TAG_READONLY & options != TAG_READONLY))
        end

        def xml_text(sym, name = nil, options = 0, wrapper = nil)
            ref = XMLTextRef.new(sym, name) do |r|
                r.cdata = (TAG_CDATA & options == TAG_CDATA)
                r.array = (TAG_ARRAY & options == TAG_ARRAY)
                r.wrapper = wrapper if wrapper
            end
            add_ref(ref)
            add_accessor(sym, (TAG_READONLY & options != TAG_READONLY), ref.array)
        end

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

    #
    # Hook on to the inclusion of this module.
    #
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
    def method_missing(name, *args)
        if name.id2name =~ /^tag_/
            self.class.__send__(name, *args)
        else
            super
        end
    end

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

