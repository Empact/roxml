require 'libxml'

module ROXML
  module XML
    include LibXML::XML
  end

  #
  # Internal base class that represents an XML - Class binding.
  #
  class XMLRef
    attr_accessor :accessor, :name, :array

    def initialize(accessor, name = nil)
      @accessor = accessor
      @name = (name || accessor.id2name).to_s
      @array = false
      yield self if block_given?
      @name = @name.singularize if @array
    end

    # Reads data from the XML element and populates the instance
    # accordingly.
    def populate(xml, instance)
      data = value(xml)
      instance.instance_variable_set("@#{accessor}", data) if data
      instance
    end
  end

  # Interal class representing an XML attribute binding
  #
  # In context:
  #  <element attribute="XMLAttributeRef">
  #   XMLTextRef
  #  </element>
  class XMLAttributeRef < XMLRef
    # Updates the attribute in the given XML block to
    # the value provided.
    def update_xml(xml, value)
      xml.attributes[name] = value.to_utf
      xml
    end

    def value(xml)
      xml.attributes[name]
    end
  end

  # Interal class representing XML content text binding
  #
  # In context:
  #  <element attribute="XMLAttributeRef">
  #   XMLTextRef
  #  </element>
  class XMLTextRef < XMLRef
    attr_accessor :cdata, :wrapper, :text_content

    # Updates the text in the given _xml_ block to
    # the _value_ provided.
    def update_xml(xml, value)
      parent = wrap(xml)
      if text_content
        parent.content = text(value)
      elsif array
        value.each do |v|
          parent.add_element(name).content = text(v)
        end
      else
        parent.add_element(name).content = text(value)
      end
      xml
    end

    def value(xml)
      if text_content
        xml.content
      elsif array
        xml.find(xpath).collect do |e|
          e.content.strip.to_latin if e.content
        end
      else
        child = xml.find_first(name)
        child.content if child
      end
    end

  private
    def text(value)
      cdata ? XML::Node.new_cdata(value.to_utf) : value.to_utf
    end

    def xpath
      wrapper ? "#{wrapper}/#{name}" : name.to_s
    end

    def wrap(xml)
      wrapper ? xml.add_element(wrapper) : xml
    end
  end

  class XMLObjectRef < XMLTextRef
    attr_reader :klass

    def initialize(accessor, klass, name = nil, &block)
      @klass = klass
      super(accessor, name, &block)
    end

    # Updates the composed XML object in the given XML block to
    # the value provided.
    def update_xml(xml, value)
      parent = wrap(xml)
      unless array
        parent.add_element(value.to_xml)
      else
        value.each do |v|
          parent.add_element(v.to_xml)
        end
      end
      xml
    end

    def value(xml)
      unless array
        if child = xml.find_first(name)
          parse(child)
        end
      else
        xml.find(xpath).collect do |e|
          parse(e)
        end
      end
    end

  private
    def parse(elem)
      if klass.respond_to? :parse
        klass.parse(elem)
      else
        klass.new(elem)
      end
    end
  end

  #
  # Returns an XML::Node representing this object.
  #
  def to_xml
    returning XML::Node.new_element(tag_name) do |root|
      tag_refs.each do |ref|
        if v = __send__(ref.accessor)
          root = ref.update_xml(root, v)
        end
      end
    end
  end
end